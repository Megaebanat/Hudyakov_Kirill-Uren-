import 'package:network/network.dart';

/// Удалённый источник данных: делегирование 11 запросов REST API библиотеке
/// [NetworkClient]. Не содержит бизнес-логики — только проксирование вызовов
/// (абстракция сетевого слоя используется через интерфейсы API-групп).
///
/// Ответственность (SRP): доступ к внешнему API.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class RemoteApiDataSource {
  /// Фасад библиотеки сетевого слоя.
  final NetworkClient _client;

  /// Создаёт удалённый источник.
  ///
  /// [client] — фасад сетевой библиотеки.
  RemoteApiDataSource(this._client);

  // --- 1-2. Авторизация и регистрация ---------------------------------------

  /// 1) Авторизация.
  Future<AuthResponseDto> login(String email, String password) =>
      _client.auth.login(email: email, password: password);

  /// 2) Регистрация.
  Future<AuthResponseDto> register({
    required String email,
    required String password,
    required String name,
  }) => _client.auth.register(email: email, password: password, name: name);

  /// 5) Выход.
  Future<void> logout() => _client.auth.logout();

  // --- 3-4. Профиль ----------------------------------------------------------

  /// 3) Изменение профиля.
  Future<UserProfileDto> updateProfile({
    String? name,
    String? photoUrl,
    bool? notificationsEnabled,
  }) => _client.profile.updateProfile(
    name: name,
    photoUrl: photoUrl,
    notificationsEnabled: notificationsEnabled,
  );

  /// 4) Получение информации о профиле.
  Future<UserProfileDto> getProfile() => _client.profile.getProfile();

  // --- 6-9. Игры --------------------------------------------------------------

  /// 6) Создание игры.
  Future<GameDto> createGame({
    required String title,
    required String category,
    required String scheduledAt,
  }) => _client.games.createGame(
    title: title,
    category: category,
    scheduledAt: scheduledAt,
  );

  /// 7) Список игр.
  Future<List<GameDto>> getGames() => _client.games.getGames();

  /// 8) Информация об игре.
  Future<GameDto> getGame(String gameId) => _client.games.getGame(gameId);

  /// 9) Подключение к игре.
  Future<GameDto> joinGame(String gameId) => _client.games.joinGame(gameId);

  /// 11) Сохранение результата игры.
  Future<void> saveResult({
    required String gameId,
    required String playerId,
    required int durationMs,
    required int moves,
    required bool completed,
  }) => _client.games.saveResult(
    gameId: gameId,
    playerId: playerId,
    durationMs: durationMs,
    moves: moves,
    completed: completed,
  );

  // --- 10. Статистика ---------------------------------------------------------

  /// 10) Статистика игрока.
  Future<StatisticsDto> getStatistics() => _client.statistics.getStatistics();
}
