import '../entities/player_statistics.dart';

/// Абстракция репозитория статистики.
///
/// Ответственность (SRP): получение статистики игрока.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract interface class StatisticsRepository {
  /// Статистика текущего игрока.
  Future<PlayerStatistics> getStatistics();
}
