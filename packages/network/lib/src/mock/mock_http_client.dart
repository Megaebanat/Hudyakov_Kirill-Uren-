import 'dart:convert';

import '../errors/network_exception.dart';
import '../http/http_client.dart';
import '../transport/http_request.dart';

/// Тестовая/демо-реализация [HttpClient] с хранилищем в памяти.
///
/// Позволяет работать приложению без реального бэкенда (демо-режим) и
/// покрывать все 11 запросов автотестами детерминированно.
/// Поддерживает имитацию отсутствия сети и ошибок сервера —
/// для проверки отображения уведомлений об ошибках.
///
/// Ответственность (SRP): эмуляция REST API в памяти процесса.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class MockHttpClient implements HttpClient {
  /// Задержка «сети» (мс).
  final int latencyMs;

  /// Имитация отсутствия соединения (бросает [ConnectionException]).
  bool simulateOffline = false;

  /// Имитация ошибки 5xx от сервера.
  bool simulateServerError = false;

  /// Пользователи: email -> (пароль, JSON профиля, JSON статистики).
  final Map<String, _MockUser> _users = {};

  /// Токен сессии -> email.
  final Map<String, String> _sessions = {};

  /// Игры (JSON-представление).
  final List<Map<String, Object?>> _games = [];

  /// Идентификатор для новых объектов.
  int _idSequence = 100;

  /// Создаёт мок-клиент с демо-данными.
  ///
  /// [latencyMs] — искусственная задержка ответа.
  MockHttpClient({this.latencyMs = 150}) {
    _seed();
  }

  // ---------------------------------------------------------------------------
  // HttpClient
  // ---------------------------------------------------------------------------

  @override
  Future<HttpResponse> get(String path, {Map<String, String> query = const {}, Map<String, String> headers = const {}}) =>
      _handle('GET', path, null, headers);

  @override
  Future<HttpResponse> post(String path, {Object? body, Map<String, String> query = const {}, Map<String, String> headers = const {}}) =>
      _handle('POST', path, body, headers);

  @override
  Future<HttpResponse> put(String path, {Object? body, Map<String, String> query = const {}, Map<String, String> headers = const {}}) =>
      _handle('PUT', path, body, headers);

  @override
  Future<HttpResponse> delete(String path, {Map<String, String> query = const {}, Map<String, String> headers = const {}}) =>
      _handle('DELETE', path, null, headers);

  // ---------------------------------------------------------------------------
  // Роутер мока
  // ---------------------------------------------------------------------------

  Future<HttpResponse> _handle(
    String method,
    String path,
    Object? body,
    Map<String, String> headers,
  ) async {
    if (latencyMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: latencyMs));
    }
    if (simulateOffline) {
      throw const ConnectionException();
    }
    if (simulateServerError) {
      return _error(
        500,
        'internal_error',
        'Внутренняя ошибка сервера. Попробуйте позже.',
      );
    }

    final uri = Uri.parse(path);
    final routePath = uri.path;
    final json = body is Map<String, Object?> ? body : null;
    final email = _currentUser(headers);

    switch ((method, routePath)) {
      // 1) Авторизация -------------------------------------------------------
      case ('POST', '/auth/login'):
        final user = _users['${json?['email'] ?? ''}'];
        if (user == null || user.password != json?['password']) {
          return _error(
            401,
            'invalid_credentials',
            'Неверный email или пароль',
          );
        }
        return _ok(_sessionFor(user));

      // 2) Регистрация -------------------------------------------------------
      case ('POST', '/auth/register'):
        final newEmail = '${json?['email'] ?? ''}';
        if (_users.containsKey(newEmail)) {
          return _error(
            409,
            'email_taken',
            'Пользователь с таким email уже существует',
          );
        }
        final user = _MockUser(
          email: newEmail,
          password: '${json?['password'] ?? ''}',
          profile: {
            'id': 'u${_idSequence++}',
            'email': newEmail,
            'name': '${json?['name'] ?? newEmail.split('@').first}',
            'photoUrl': null,
            'rating': 0,
            'notificationsEnabled': false,
          },
        );
        _users[newEmail] = user;
        return _ok(_sessionFor(user));

      // 5) Выход --------------------------------------------------------------
      case ('POST', '/auth/logout'):
        if (email == null) return _error(401, 'unauthorized', 'Требуется авторизация');
        _sessions.remove(headers['Authorization']?.replaceFirst('Bearer ', ''));
        return _ok(const <String, Object?>{});

      // 4) Получение информации о профиле ------------------------------------
      case ('GET', '/profile'):
        if (email == null) return _error(401, 'unauthorized', 'Требуется авторизация');
        return _ok(_users[email]!.profile);

      // 3) Изменение профиля --------------------------------------------------
      case ('PUT', '/profile'):
        if (email == null) return _error(401, 'unauthorized', 'Требуется авторизация');
        final user = _users[email]!;
        user.profile = {
          ...user.profile,
          if (json?['name'] != null) 'name': json!['name'],
          if (json?['photoUrl'] != null) 'photoUrl': json!['photoUrl'],
          if (json?['notificationsEnabled'] != null)
            'notificationsEnabled': json!['notificationsEnabled'],
        };
        return _ok(user.profile);

      // 6) Создание игры ------------------------------------------------------
      case ('POST', '/games'):
        if (email == null) return _error(401, 'unauthorized', 'Требуется авторизация');
        final creator = _users[email]!.profile;
        final game = <String, Object?>{
          'id': 'g${_idSequence++}',
          'title': '${json?['title'] ?? 'Новая игра'}',
          'category': '${json?['category'] ?? 'image'}',
          'scheduledAt': '${json?['scheduledAt'] ?? ''}',
          'creator': creator,
          'opponent': null,
          'status': 'waiting',
          'winnerId': null,
        };
        _games.insert(0, game);
        return _ok(game);

      // 7) Список игр ---------------------------------------------------------
      case ('GET', '/games'):
        if (email == null) return _error(401, 'unauthorized', 'Требуется авторизация');
        return _ok(_games);

      // 8) Информация об игре / 9) Подключение --------------------------------
      case (final m, final route) when route.endsWith('/join') && m == 'POST':
        if (email == null) return _error(401, 'unauthorized', 'Требуется авторизация');
        final id = route.split('/')[2];
        final game = _gameById(id);
        if (game == null) return _error(404, 'not_found', 'Игра не найдена');
        final creatorId = (game['creator'] as Map<String, Object?>?)?['id'];
        final meId = _users[email]!.profile['id'];
        if (creatorId == meId) {
          return _error(409, 'already_creator', 'Вы создатель этой игры');
        }
        if (game['opponent'] != null) {
          return _error(409, 'opponent_exists', 'У игры уже есть соперник');
        }
        game['opponent'] = _users[email]!.profile;
        game['status'] = 'upcoming';
        return _ok(game);

      case ('GET', final route) when route.startsWith('/games/'):
        if (email == null) return _error(401, 'unauthorized', 'Требуется авторизация');
        final id = route.split('/')[2];
        final game = _gameById(id);
        if (game == null) return _error(404, 'not_found', 'Игра не найдена');
        return _ok(game);

      // 11) Сохранение результата игры ---------------------------------------
      case ('POST', final route) when route.endsWith('/results'):
        if (email == null) return _error(401, 'unauthorized', 'Требуется авторизация');
        final id = route.split('/')[2];
        final game = _gameById(id);
        if (game == null) return _error(404, 'not_found', 'Игра не найдена');
        final completed = json?['completed'] == true;
        final stats = _users[email]!.stats;
        if (completed) {
          game['status'] = 'finished';
          game['winnerId'] = json?['playerId'];
          final category = '${game['category']}';
          // Вложенный формат playedGames соответствует контракту StatisticsDto.
          final played = stats['playedGames'] as Map<String, Object?>;
          final key = category == 'circle' ? 'circle' : 'image';
          played[key] = (played[key] as int) + 1;
          stats['weekEarnings'] = (stats['weekEarnings'] as int) + 100;
        }
        return _ok(const <String, Object?>{'saved': true});

      // 10) Статистика игрока --------------------------------------------------
      case ('GET', '/statistics'):
        if (email == null) return _error(401, 'unauthorized', 'Требуется авторизация');
        return _ok(_users[email]!.stats);

      default:
        return _error(
          404,
          'not_found',
          'Эндпоинт не найден: $method $routePath',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Вспомогательные методы
  // ---------------------------------------------------------------------------

  /// Ищет email текущего пользователя по заголовку Authorization.
  ///
  /// [headers] — заголовки запроса; null — не авторизован.
  String? _currentUser(Map<String, String> headers) {
    final token = headers['Authorization']?.replaceFirst('Bearer ', '');
    if (token == null || token.isEmpty) return null;
    return _sessions[token];
  }

  /// Формирует тело ответа входа/регистрации с токеном.
  ///
  /// [user] — пользователь; возвращает JSON с токеном и профилем.
  Map<String, Object?> _sessionFor(_MockUser user) {
    final token = 'token-${user.email}-${_idSequence++}';
    _sessions[token] = user.email;
    return {'token': token, 'user': user.profile};
  }

  /// Ищет игру по [id].
  ///
  /// [id] — идентификатор; null, если не найдена.
  Map<String, Object?>? _gameById(String id) {
    for (final game in _games) {
      if (game['id'] == id) return game;
    }
    return null;
  }

  /// Успешный JSON-ответ (200).
  ///
  /// [data] — полезная нагрузка.
  HttpResponse _ok(Object? data) => HttpResponse(
        statusCode: 200,
        headers: const {'content-type': 'application/json'},
        body: jsonEncode(data),
      );

  /// JSON-ответ с ошибкой.
  ///
  /// [status] — HTTP-статус; [code] — код; [message] — сообщение.
  HttpResponse _error(int status, String code, String message) => HttpResponse(
        statusCode: status,
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'error': {'code': code, 'message': message},
        }),
      );

  /// Наполняет мок демо-данными (пользователь + игры разных статусов).
  void _seed() {
    final demo = _MockUser(
      email: 'demo@mail.ru',
      password: '123456',
      profile: {
        'id': 'u1',
        'email': 'demo@mail.ru',
        'name': 'Демо Игрок',
        'photoUrl': null,
        'rating': 240,
        'notificationsEnabled': true,
      },
    );
    _users[demo.email] = demo;

    final opponent = const <String, Object?>{
      'id': 'u2',
      'email': 'rival@mail.ru',
      'name': 'Соперник',
      'photoUrl': null,
      'rating': 310,
      'notificationsEnabled': false,
    };
    final friend = const <String, Object?>{
      'id': 'u3',
      'email': 'friend@mail.ru',
      'name': 'Друг',
      'photoUrl': null,
      'rating': 150,
      'notificationsEnabled': false,
    };

    final now = DateTime.now();
    _games.addAll([
      {
        'id': 'g1',
        'title': 'Вечерний турнир',
        'category': 'circle',
        'scheduledAt': now.add(const Duration(hours: 3)).toIso8601String(),
        'creator': demo.profile,
        'opponent': null,
        'status': 'waiting',
        'winnerId': null,
      },
      {
        'id': 'g2',
        'title': 'Матч недели',
        'category': 'image',
        'scheduledAt': now.add(const Duration(days: 1)).toIso8601String(),
        'creator': demo.profile,
        'opponent': friend,
        'status': 'upcoming',
        'winnerId': null,
      },
      {
        'id': 'g3',
        'title': 'Утренний бой',
        'category': 'image',
        'scheduledAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'creator': opponent,
        'opponent': demo.profile,
        'status': 'finished',
        'winnerId': 'u1',
      },
      {
        'id': 'g4',
        'title': 'Прошлый турнир',
        'category': 'circle',
        'scheduledAt': now.subtract(const Duration(days: 5)).toIso8601String(),
        'creator': friend,
        'opponent': demo.profile,
        'status': 'finished',
        'winnerId': 'u3',
      },
      {
        'id': 'g5',
        'title': 'Открытый бой',
        'category': 'circle',
        'scheduledAt': now.add(const Duration(days: 2)).toIso8601String(),
        'creator': opponent,
        'opponent': null,
        'status': 'waiting',
        'winnerId': null,
      },
    ]);

    demo.stats.addAll({
      'weekEarnings': 320,
      'playedGames': {'circle': 2, 'image': 3},
      'scheduledGames': 4,
    });
  }
}

/// Внутренняя модель пользователя мока.
class _MockUser {
  /// Email (ключ хранилища).
  final String email;

  /// Пароль (для проверки входа).
  final String password;

  /// JSON профиля.
  Map<String, Object?> profile;

  /// JSON статистики (контракт StatisticsDto: weekEarnings,
  /// playedGames{circle,image}, scheduledGames).
  final Map<String, Object?> stats = {
    'weekEarnings': 0,
    'playedGames': {'circle': 0, 'image': 0},
    'scheduledGames': 0,
  };

  /// Создаёт пользователя мока.
  ///
  /// [email] — почта; [password] — пароль; [profile] — JSON профиля.
  _MockUser({
    required this.email,
    required this.password,
    required this.profile,
  });
}
