import '../../domain/entities/app_user.dart';

/// Аргументы маршрутов (типизированная передача данных между экранами).
///
/// Аргументы собраны в одном файле, чтобы маршрутизатор и экраны
/// использовали одни и те же типы (DRY) и не привязывались к `dynamic`.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00

/// Аргументы экранов, работающих с конкретной игрой.
class GameRouteArgs {
  /// Идентификатор игры.
  final String gameId;

  /// Создаёт аргументы.
  ///
  /// [gameId] — идентификатор игры.
  const GameRouteArgs(this.gameId);
}

/// Аргументы экрана «Информация об игроке».
class PlayerRouteArgs {
  /// Данные игрока (из списка/профиля).
  final AppUser user;

  /// Экран открыт для собственного профиля (доступна смена фото).
  final bool isOwnProfile;

  /// Создаёт аргументы.
  ///
  /// [user] — игрок; [isOwnProfile] — собственный профиль ли это.
  const PlayerRouteArgs(this.user, {this.isOwnProfile = false});
}

/// Аргументы экрана «Успех».
class SuccessRouteArgs {
  /// Текст подтверждения (например, «Игра опубликована»).
  final String message;

  /// Создаёт аргументы.
  ///
  /// [message] — текст для пользователя.
  const SuccessRouteArgs(this.message);
}
