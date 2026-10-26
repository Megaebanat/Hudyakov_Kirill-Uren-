import 'package:network/network.dart';
import 'package:test/test.dart';

/// Автотесты библиотеки сетевого слоя: каждый из 11 запросов API
/// проверяется по тест-кейсу «предусловие → шаги → ожидаемый результат»
/// с использованием мок-клиента (детерминированно, без реальной сети).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
void main() {
  late MockHttpClient mock;
  late String? token;
  late NetworkClient api;

  setUp(() {
    mock = MockHttpClient(latencyMs: 0);
    token = null;
    api = NetworkFactory.create(
      config: const ApiConfig(baseUrl: 'https://mock.local'),
      client: AuthenticatedHttpClient(inner: mock, tokenProvider: () => token),
    );
  });

  group('1-2. Авторизация и регистрация', () {
    test('1. Успешный POST-запрос входа с десериализацией', () async {
      // Шаги: вызвать login с корректными данными демо-пользователя.
      final result = await api.auth.login(
        email: 'demo@mail.ru',
        password: '123456',
      );
      // Ожидаемый результат: токен непустой, профиль соответствует JSON.
      expect(result.token, isNotEmpty);
      expect(result.user.email, 'demo@mail.ru');
      expect(result.user.name, 'Демо Игрок');
    });

    test('1. Неверный пароль -> UnauthorizedException с сообщением', () async {
      // Предусловие: пароль не совпадает.
      // Шаги: вход с неверным паролем.
      // Ожидаемый результат: 401 превращён в типизированную ошибку.
      await expectLater(
        api.auth.login(email: 'demo@mail.ru', password: 'bad'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('2. Регистрация создаёт пользователя и возвращает сессию', () async {
      final result = await api.auth.register(
        email: 'new@mail.ru',
        password: 'qwerty',
        name: 'Новичок',
      );
      expect(result.token, isNotEmpty);
      expect(result.user.email, 'new@mail.ru');
      expect(result.user.name, 'Новичок');
    });

    test('2. Повторная регистрация -> конфликт (409)', () async {
      await api.auth.register(
        email: 'dup@mail.ru',
        password: 'qwerty',
        name: 'Дубль',
      );
      await expectLater(
        api.auth.register(email: 'dup@mail.ru', password: 'x', name: 'Дубль'),
        throwsA(isA<ApiErrorException>()),
      );
    });

    test('5. Выход завершает сессию', () async {
      final session = await api.auth.login(
        email: 'demo@mail.ru',
        password: '123456',
      );
      token = session.token;
      await api.auth.logout();
      // После выхода защищённые методы требуют авторизации.
      token = null;
      await expectLater(
        api.profile.getProfile(),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('3-4. Профиль', () {
    setUp(() async {
      final session = await api.auth.login(
        email: 'demo@mail.ru',
        password: '123456',
      );
      token = session.token;
    });

    test('4. Получение информации о профиле', () async {
      final profile = await api.profile.getProfile();
      expect(profile.email, 'demo@mail.ru');
      expect(profile.id, 'u1');
    });

    test('3. Изменение профиля (имя и уведомления)', () async {
      final updated = await api.profile.updateProfile(
        name: 'Новое Имя',
        notificationsEnabled: false,
      );
      expect(updated.name, 'Новое Имя');
      expect(updated.notificationsEnabled, false);
      // Неизменённые поля сохраняются.
      expect(updated.email, 'demo@mail.ru');
    });
  });

  group('6-9. Игры', () {
    setUp(() async {
      final session = await api.auth.login(
        email: 'demo@mail.ru',
        password: '123456',
      );
      token = session.token;
    });

    test('6. Создание игры', () async {
      final game = await api.games.createGame(
        title: 'Тестовая игра',
        category: 'circle',
        scheduledAt: '2027-01-01T18:00:00.000',
      );
      expect(game.title, 'Тестовая игра');
      expect(game.category, GameCategoryDto.circle);
      expect(game.status, GameStatusDto.waiting);
      expect(game.creator.email, 'demo@mail.ru');
    });

    test('7. Список игр содержит демо-игры', () async {
      final games = await api.games.getGames();
      expect(games, isNotEmpty);
      expect(games.first.id, isNotEmpty);
    });

    test('8. Информация об игре по идентификатору', () async {
      final game = await api.games.getGame('g2');
      expect(game.id, 'g2');
      expect(game.category, GameCategoryDto.image);
      expect(game.opponent, isNotNull);
    });

    test('8. Несуществующая игра -> NotFoundException', () async {
      await expectLater(
        api.games.getGame('missing'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('9. Подключение к игре без соперника', () async {
      // Предусловие: в игре g5 соперник отсутствует, создатель — другой игрок.
      final joined = await api.games.joinGame('g5');
      expect(joined.opponent?.email, 'demo@mail.ru');
      expect(joined.status, GameStatusDto.upcoming);
    });

    test('9. Подключение к своей игре -> конфликт', () async {
      await expectLater(
        api.games.joinGame('g2'),
        throwsA(isA<ApiErrorException>()),
      );
    });
  });

  group('10-11. Статистика и результаты', () {
    setUp(() async {
      final session = await api.auth.login(
        email: 'demo@mail.ru',
        password: '123456',
      );
      token = session.token;
    });

    test('10. Статистика игрока соответствует JSON', () async {
      final stats = await api.statistics.getStatistics();
      expect(stats.weekEarnings, 320);
      expect(stats.circleWins, 2);
      expect(stats.imageWins, 3);
      expect(stats.scheduledGames, 4);
    });

    test('11. Сохранение результата победы обновляет статистику', () async {
      await api.games.saveResult(
        gameId: 'g2',
        playerId: 'u1',
        durationMs: 4200,
        moves: 17,
        completed: true,
      );
      final stats = await api.statistics.getStatistics();
      // Победа в image: +1 победа, +100 очков за неделю.
      expect(stats.imageWins, 4);
      expect(stats.weekEarnings, 420);
    });

    test('11. Незавершённая игра не приносит очков', () async {
      await api.games.saveResult(
        gameId: 'g2',
        playerId: 'u1',
        durationMs: 1000,
        moves: 3,
        completed: false,
      );
      final stats = await api.statistics.getStatistics();
      expect(stats.weekEarnings, 320);
    });
  });

  group('Обработка ошибок сети', () {
    test('Нет соединения -> ConnectionException', () async {
      mock.simulateOffline = true;
      await expectLater(
        api.auth.login(email: 'demo@mail.ru', password: '123456'),
        throwsA(isA<ConnectionException>()),
      );
    });

    test('Ошибка 5xx -> ServerException', () async {
      mock.simulateServerError = true;
      await expectLater(
        api.auth.login(email: 'demo@mail.ru', password: '123456'),
        throwsA(
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('Без токена защищённые методы -> UnauthorizedException', () async {
      await expectLater(
        api.statistics.getStatistics(),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}
