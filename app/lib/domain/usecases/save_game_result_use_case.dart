import '../entities/game_result.dart';
import '../repositories/game_repository.dart';

/// Use case: сохранение результата игры на сервере.
///
/// Ответственность (SRP): единственный сценарий сохранения результата.
/// Вызывается при автоматическом завершении собранной головоломки и при
/// досрочном выходе из игры (проигрыш: completed = false).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class SaveGameResultUseCase {
  /// Репозиторий игр (абстракция — DIP).
  final GameRepository repository;

  /// Создаёт use case.
  ///
  /// [repository] — репозиторий игр.
  SaveGameResultUseCase(this.repository);

  /// Сохраняет результат.
  ///
  /// [result] — результат игры; возвращает Future завершения.
  Future<void> call(GameResult result) => repository.saveResult(result);
}
