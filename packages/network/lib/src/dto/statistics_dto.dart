/// DTO статистики игрока.
///
/// Ответственность (SRP): описание сетевой модели статистики экрана Statistics.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class StatisticsDto {
  /// Сумма очков, заработанных на этой неделе (THIS WEEK EARNINGS).
  final int weekEarnings;

  /// Количество выигранных игр в категории «Круг».
  final int circleWins;

  /// Количество выигранных игр в категории «Картинка».
  final int imageWins;

  /// Количество созданных игр за текущую неделю (SCHEDULED GAMES).
  final int scheduledGames;

  /// Создаёт DTO статистики.
  ///
  /// [weekEarnings] — очки за неделю; [circleWins] — победы «Круг»;
  /// [imageWins] — победы «Картинка»; [scheduledGames] — игры за неделю.
  const StatisticsDto({
    required this.weekEarnings,
    required this.circleWins,
    required this.imageWins,
    required this.scheduledGames,
  });

  /// Разбирает DTO из JSON [json].
  factory StatisticsDto.fromJson(Map<String, Object?> json) {
    final played = json['playedGames'] as Map<String, Object?>? ?? const {};
    return StatisticsDto(
      weekEarnings: (json['weekEarnings'] as num?)?.toInt() ?? 0,
      circleWins: (played['circle'] as num?)?.toInt() ?? 0,
      imageWins: (played['image'] as num?)?.toInt() ?? 0,
      scheduledGames: (json['scheduledGames'] as num?)?.toInt() ?? 0,
    );
  }

  /// Сериализует DTO в JSON.
  Map<String, Object?> toJson() => {
        'weekEarnings': weekEarnings,
        'playedGames': {'circle': circleWins, 'image': imageWins},
        'scheduledGames': scheduledGames,
      };
}
