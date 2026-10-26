import 'app_user.dart';

/// Категория игры (доменная модель).
enum GameCategory {
  /// Игра «Картинка»: сборка изображения из фрагментов.
  image,

  /// Игра «Круг»: сборка кругов от большего к меньшему.
  circle,
}

/// Статус игры (доменная модель).
enum GameStatus {
  /// Ожидает соперника.
  waiting,

  /// Предстоящая игра назначена.
  upcoming,

  /// Идёт сейчас.
  inProgress,

  /// Завершена.
  finished,
}

/// Доменная сущность «Игра».
///
/// Ответственность (SRP): описание игрового события предметной области.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class Game {
  /// Идентификатор игры.
  final String id;

  /// Название.
  final String title;

  /// Категория (image/circle).
  final GameCategory category;

  /// Дата и время начала.
  final DateTime scheduledAt;

  /// Создатель игры.
  final AppUser creator;

  /// Соперник (null — ещё не подключился).
  final AppUser? opponent;

  /// Текущий статус.
  final GameStatus status;

  /// Идентификатор победителя (null — не определён).
  final String? winnerId;

  /// Создаёт игру.
  ///
  /// [id] — идентификатор; [title] — название; [category] — категория;
  /// [scheduledAt] — время начала; [creator] — создатель;
  /// [opponent] — соперник; [status] — статус; [winnerId] — победитель.
  const Game({
    required this.id,
    required this.title,
    required this.category,
    required this.scheduledAt,
    required this.creator,
    this.opponent,
    required this.status,
    this.winnerId,
  });

  /// Игра ещё ожидает соперника.
  bool get needsOpponent => opponent == null && status == GameStatus.waiting;

  /// Текущий пользователь — создатель игры.
  bool createdBy(String userId) => creator.id == userId;

  /// Текущий пользователь уже участвует в игре.
  bool containsPlayer(String userId) =>
      creator.id == userId || opponent?.id == userId;

  /// Победил указанный игрок.
  bool wonBy(String userId) => winnerId == userId;
}
