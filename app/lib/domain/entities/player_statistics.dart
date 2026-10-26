/// Доменная сущность «Статистика игрока» (экран Statistics).
///
/// Ответственность (SRP): агрегированные показатели игрока.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class PlayerStatistics {
  /// Сумма очков за текущую неделю (THIS WEEK EARNINGS).
  final int weekEarnings;

  /// Победы в категории «Круг» (Синий круг).
  final int circleWins;

  /// Победы в категории «Картинка» (Красный Image).
  final int imageWins;

  /// Созданные игры за текущую неделю (SCHEDULED GAMES).
  final int scheduledGames;

  /// Создаёт статистику.
  ///
  /// [weekEarnings] — очки; [circleWins] — победы «Круг»;
  /// [imageWins] — победы «Картинка»; [scheduledGames] — игры недели.
  const PlayerStatistics({
    required this.weekEarnings,
    required this.circleWins,
    required this.imageWins,
    required this.scheduledGames,
  });

  /// Пустая статистика (до первой загрузки).
  static const PlayerStatistics empty = PlayerStatistics(
    weekEarnings: 0,
    circleWins: 0,
    imageWins: 0,
    scheduledGames: 0,
  );

  /// Всего выигранных игр (PLAYED GAMES).
  int get totalWins => circleWins + imageWins;
}
