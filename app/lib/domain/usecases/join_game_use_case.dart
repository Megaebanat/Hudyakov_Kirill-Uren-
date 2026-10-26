import '../entities/game.dart';
import '../errors/domain_exception.dart';
import '../repositories/game_repository.dart';

/// Use case: подключение игрока к игре (войти в игру без соперника).
///
/// Ответственность (SRP): координация подключения к игре.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class JoinGameUseCase {
  /// Репозиторий игр (абстракция — DIP).
  final GameRepository repository;

  /// Создаёт use case.
  ///
  /// [repository] — репозиторий игр.
  JoinGameUseCase(this.repository);

  /// Подключает текущего пользователя к игре [gameId].
  ///
  /// [gameId] — идентификатор игры; возвращает обновлённый [Game].
  /// Бросает [ValidationException], если в игре уже есть соперник.
  Future<Game> call(String gameId, {required bool isCreator}) async {
    if (isCreator) {
      throw const ValidationException('Вы создатель этой игры');
    }
    return repository.joinGame(gameId);
  }
}
