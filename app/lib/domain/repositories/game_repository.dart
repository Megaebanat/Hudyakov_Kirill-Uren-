import '../entities/game.dart';
import '../entities/game_result.dart';

/// Абстракция репозитория игр.
///
/// Ответственность (SRP): сценарии игрового процесса.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract interface class GameRepository {
  /// Создаёт игру на сервере.
  ///
  /// [title] — название; [category] — категория; [scheduledAt] — время начала.
  Future<Game> createGame({
    required String title,
    required GameCategory category,
    required DateTime scheduledAt,
  });

  /// Список всех игр (предстоящих и прошедших).
  Future<List<Game>> getGames();

  /// Детальная информация об игре [gameId].
  Future<Game> getGame(String gameId);

  /// Подключение текущего пользователя к игре [gameId].
  Future<Game> joinGame(String gameId);

  /// Сохранение результата [result] на сервере.
  Future<void> saveResult(GameResult result);
}
