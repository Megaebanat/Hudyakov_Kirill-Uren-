import 'package:network/network.dart';

import '../../domain/entities/player_statistics.dart';

/// Маппер DTO ↔ доменная сущность статистики.
///
/// Ответственность (SRP): только преобразование модели статистики.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract final class StatisticsMapper {
  /// DTO сервера → доменная сущность.
  ///
  /// [dto] — DTO статистики; возвращает [PlayerStatistics].
  static PlayerStatistics toEntity(StatisticsDto dto) => PlayerStatistics(
    weekEarnings: dto.weekEarnings,
    circleWins: dto.circleWins,
    imageWins: dto.imageWins,
    scheduledGames: dto.scheduledGames,
  );
}
