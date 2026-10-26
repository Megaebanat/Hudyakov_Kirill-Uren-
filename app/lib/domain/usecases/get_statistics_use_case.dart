import '../entities/player_statistics.dart';
import '../repositories/statistics_repository.dart';

/// Use case: получение статистики игрока (экран Statistics).
///
/// Ответственность (SRP): единственный сценарий загрузки статистики.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GetStatisticsUseCase {
  /// Репозиторий статистики (абстракция — DIP).
  final StatisticsRepository repository;

  /// Создаёт use case.
  ///
  /// [repository] — репозиторий статистики.
  GetStatisticsUseCase(this.repository);

  /// Загружает статистику.
  ///
  /// Без параметров; возвращает [PlayerStatistics].
  Future<PlayerStatistics> call() => repository.getStatistics();
}
