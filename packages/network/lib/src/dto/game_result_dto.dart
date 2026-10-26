/// DTO результата игры, который клиент отправляет на сервер.
///
/// Ответственность (SRP): описание полезной нагрузки сохранения результата.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GameResultDto {
  /// Идентификатор игры.
  final String gameId;

  /// Идентификатор игрока.
  final String playerId;

  /// Затраченное время (миллисекунды).
  final int durationMs;

  /// Количество ходов/действий.
  final int moves;

  /// Завершил ли игрок сборку (закрытие игры до конца = поражение).
  final bool completed;

  /// Создаёт DTO результата.
  ///
  /// [gameId] — игра; [playerId] — игрок; [durationMs] — время;
  /// [moves] — ходы; [completed] — собрана ли головоломка.
  const GameResultDto({
    required this.gameId,
    required this.playerId,
    required this.durationMs,
    required this.moves,
    required this.completed,
  });

  /// Разбирает DTO из JSON [json].
  factory GameResultDto.fromJson(Map<String, Object?> json) => GameResultDto(
        gameId: '${json['gameId']}',
        playerId: '${json['playerId']}',
        durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
        moves: (json['moves'] as num?)?.toInt() ?? 0,
        completed: json['completed'] as bool? ?? false,
      );

  /// Сериализует DTO в JSON (тело запроса «Сохранение результата игры»).
  Map<String, Object?> toJson() => {
        'gameId': gameId,
        'playerId': playerId,
        'durationMs': durationMs,
        'moves': moves,
        'completed': completed,
      };
}
