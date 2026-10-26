/// DTO игры и связанных моделей игрового процесса.
///
/// Ответственность (SRP): описание сетевой модели игры.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
library;

import 'auth_dto.dart';

/// Категория игры.
enum GameCategoryDto {
  /// Игра «Картинка» (сборка изображения из фрагментов).
  image,

  /// Игра «Круг» (сборка кругов от большего к меньшему).
  circle;

  /// Разбирает категорию из строки сервера ([raw], например `"image"`).
  ///
  /// [raw] — строка категории; по умолчанию — [GameCategoryDto.image].
  static GameCategoryDto parse(String raw) => GameCategoryDto.values
      .firstWhere((value) => value.name == raw, orElse: () => image);
}

/// Статус игры.
enum GameStatusDto {
  /// Игра ожидает соперника.
  waiting,

  /// Предстоящая игра (назначена, но не начата).
  upcoming,

  /// Игра идёт.
  inProgress,

  /// Игра завершена.
  finished;

  /// Разбирает статус из строки сервера ([raw]).
  ///
  /// [raw] — строка статуса; по умолчанию — [GameStatusDto.upcoming].
  static GameStatusDto parse(String raw) => GameStatusDto.values
      .firstWhere((value) => value.name == raw, orElse: () => upcoming);
}

/// Игра в формате сервера.
class GameDto {
  /// Идентификатор игры.
  final String id;

  /// Название игры.
  final String title;

  /// Категория (image/circle).
  final GameCategoryDto category;

  /// Дата и время начала (ISO-8601).
  final String scheduledAt;

  /// Профиль создателя.
  final UserProfileDto creator;

  /// Профиль соперника (null — соперник ещё не подключился).
  final UserProfileDto? opponent;

  /// Текущий статус.
  final GameStatusDto status;

  /// Идентификатор победителя (null — игра не завершена).
  final String? winnerId;

  /// Создаёт DTO игры.
  ///
  /// [id] — идентификатор; [title] — название; [category] — категория;
  /// [scheduledAt] — время начала; [creator] — создатель;
  /// [opponent] — соперник; [status] — статус; [winnerId] — победитель.
  const GameDto({
    required this.id,
    required this.title,
    required this.category,
    required this.scheduledAt,
    required this.creator,
    this.opponent,
    required this.status,
    this.winnerId,
  });

  /// Разбирает DTO из JSON [json].
  factory GameDto.fromJson(Map<String, Object?> json) => GameDto(
        id: '${json['id']}',
        title: '${json['title'] ?? 'Игра'}',
        category: GameCategoryDto.parse('${json['category'] ?? 'image'}'),
        scheduledAt: '${json['scheduledAt'] ?? ''}',
        creator: UserProfileDto.fromJson(
          (json['creator'] as Map<String, Object?>?) ?? const {},
        ),
        opponent: json['opponent'] is Map<String, Object?>
            ? UserProfileDto.fromJson(json['opponent'] as Map<String, Object?>)
            : null,
        status: GameStatusDto.parse('${json['status'] ?? 'upcoming'}'),
        winnerId: json['winnerId'] as String?,
      );

  /// Сериализует DTO в JSON.
  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'scheduledAt': scheduledAt,
        'creator': creator.toJson(),
        'opponent': opponent?.toJson(),
        'status': status.name,
        'winnerId': winnerId,
      };
}
