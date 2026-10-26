import '../entities/game.dart';
import '../repositories/game_repository.dart';

/// Use case: получение списка всех игр (Discover Combats).
///
/// Ответственность (SRP): единственный сценарий загрузки списка игр.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GetGamesUseCase {
  /// Репозиторий игр (абстракция — DIP).
  final GameRepository repository;

  /// Создаёт use case.
  ///
  /// [repository] — репозиторий игр.
  GetGamesUseCase(this.repository);

  /// Загружает список игр (новые вперёд).
  ///
  /// Без параметров; возвращает список [Game].
  Future<List<Game>> call() => repository.getGames();
}
