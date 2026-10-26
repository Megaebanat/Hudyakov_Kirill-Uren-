import '../../common/logging/app_logger.dart';
import '../../domain/entities/player_statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/remote_api_data_source.dart';
import '../mappers/error_mapper.dart';
import '../mappers/statistics_mapper.dart';

/// Реализация [StatisticsRepository]: REST API статистики.
///
/// Ответственность (SRP): загрузка статистики игрока.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class StatisticsRepositoryImpl implements StatisticsRepository {
  /// Удалённый источник данных.
  final RemoteApiDataSource _api;

  /// Создаёт реализацию.
  ///
  /// [api] — удалённый источник.
  StatisticsRepositoryImpl({required this._api});

  @override
  Future<PlayerStatistics> getStatistics() async {
    try {
      AppLogger.info(
        'StatisticsRepository',
        'Загрузка статистики',
        'Запрос отправлен',
      );
      final dto = await _api.getStatistics();
      final statistics = StatisticsMapper.toEntity(dto);
      AppLogger.debug(
        'StatisticsRepository',
        'Загрузка статистики',
        'Очки за неделю: ${statistics.weekEarnings}',
      );
      return statistics;
    } catch (error, stackTrace) {
      AppLogger.error(
        'StatisticsRepository',
        'Загрузка статистики — ошибка',
        error,
        stackTrace,
      );
      throw ErrorMapper.map(error);
    }
  }
}
