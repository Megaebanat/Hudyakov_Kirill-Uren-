/// Доменная сущность «Результат игры» (то, что клиент отправляет на сервер).
///
/// Ответственность (SRP): описание итога игровой сессии.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GameResult {
  /// Идентификатор игры.
  final String gameId;

  /// Идентификатор игрока.
  final String playerId;

  /// Затраченное время (миллисекунды).
  final int durationMs;

  /// Количество ходов.
  final int moves;

  /// Головоломка собрана до конца (иначе — игрок закрыл игру и проиграл).
  final bool completed;

  /// Создаёт результат.
  ///
  /// [gameId] — игра; [playerId] — игрок; [durationMs] — время;
  /// [moves] — ходы; [completed] — собрана ли головоломка.
  const GameResult({
    required this.gameId,
    required this.playerId,
    required this.durationMs,
    required this.moves,
    required this.completed,
  });
}
