import 'package:network/network.dart';

import '../../domain/entities/game.dart';
import 'user_mapper.dart';

/// Маппер DTO ↔ доменная сущность игры.
///
/// Ответственность (SRP): только преобразование модели игры.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract final class GameMapper {
  /// DTO сервера → доменная сущность.
  ///
  /// [dto] — DTO игры; возвращает [Game].
  static Game toEntity(GameDto dto) => Game(
    id: dto.id,
    title: dto.title,
    category: switch (dto.category) {
      GameCategoryDto.image => GameCategory.image,
      GameCategoryDto.circle => GameCategory.circle,
    },
    scheduledAt: DateTime.tryParse(dto.scheduledAt) ?? DateTime.now(),
    creator: UserMapper.toEntity(dto.creator),
    opponent: dto.opponent == null ? null : UserMapper.toEntity(dto.opponent!),
    status: switch (dto.status) {
      GameStatusDto.waiting => GameStatus.waiting,
      GameStatusDto.upcoming => GameStatus.upcoming,
      GameStatusDto.inProgress => GameStatus.inProgress,
      GameStatusDto.finished => GameStatus.finished,
    },
    winnerId: dto.winnerId,
  );

  /// Доменная сущность → DTO (для локального кэша списков игр).
  ///
  /// [game] — сущность; возвращает [GameDto].
  static GameDto toDto(Game game) => GameDto(
    id: game.id,
    title: game.title,
    category: switch (game.category) {
      GameCategory.image => GameCategoryDto.image,
      GameCategory.circle => GameCategoryDto.circle,
    },
    scheduledAt: game.scheduledAt.toIso8601String(),
    creator: UserMapper.toDto(game.creator),
    opponent: game.opponent == null ? null : UserMapper.toDto(game.opponent!),
    status: switch (game.status) {
      GameStatus.waiting => GameStatusDto.waiting,
      GameStatus.upcoming => GameStatusDto.upcoming,
      GameStatus.inProgress => GameStatusDto.inProgress,
      GameStatus.finished => GameStatusDto.finished,
    },
    winnerId: game.winnerId,
  );
}
