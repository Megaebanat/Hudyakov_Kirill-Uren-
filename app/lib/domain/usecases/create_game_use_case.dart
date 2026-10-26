import '../entities/game.dart';
import '../errors/domain_exception.dart';
import '../repositories/game_repository.dart';

/// Use case: создание игры (экран Schedule Game).
///
/// Ответственность (SRP): валидация формы создания игры.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class CreateGameUseCase {
  /// Репозиторий игр (абстракция — DIP).
  final GameRepository repository;

  /// Создаёт use case.
  ///
  /// [repository] — репозиторий игр.
  CreateGameUseCase(this.repository);

  /// Создаёт игру на сервере.
  ///
  /// [title] — название; [category] — категория; [scheduledAt] — время;
  /// возвращает [Game]. Бросает [ValidationException] при пустом названии
  /// или времени в прошлом.
  Future<Game> call({
    required String title,
    required GameCategory category,
    required DateTime scheduledAt,
  }) async {
    if (title.trim().isEmpty) {
      throw const ValidationException('Введите название игры');
    }
    if (scheduledAt.isBefore(DateTime.now())) {
      throw const ValidationException('Время игры не может быть в прошлом');
    }
    return repository.createGame(
      title: title.trim(),
      category: category,
      scheduledAt: scheduledAt,
    );
  }
}
