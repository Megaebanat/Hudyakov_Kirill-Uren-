import '../entities/game.dart';
import '../repositories/game_repository.dart';

/// Use case: получение информации об игре (Combat Information).
///
/// Ответственность (SRP): единственный сценарий загрузки игры по id.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GetGameUseCase {
  /// Репозиторий игр (абстракция — DIP).
  final GameRepository repository;

  /// Создаёт use case.
  ///
  /// [repository] — репозиторий игр.
  GetGameUseCase(this.repository);

  /// Загружает игру [gameId].
  ///
  /// [gameId] — идентификатор игры; возвращает [Game].
  Future<Game> call(String gameId) => repository.getGame(gameId);
}
