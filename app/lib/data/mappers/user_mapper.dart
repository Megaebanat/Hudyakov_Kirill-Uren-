import 'package:network/network.dart';

import '../../domain/entities/app_user.dart';

/// Маппер DTO ↔ доменная сущность пользователя (граница data-слоя).
///
/// Ответственность (SRP): только преобразование модели пользователя.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract final class UserMapper {
  /// DTO сервера → доменная сущность.
  ///
  /// [dto] — DTO профиля; возвращает [AppUser].
  static AppUser toEntity(UserProfileDto dto) => AppUser(
    id: dto.id,
    email: dto.email,
    name: dto.name,
    photoUrl: dto.photoUrl,
    rating: dto.rating,
    notificationsEnabled: dto.notificationsEnabled,
  );

  /// Доменная сущность → DTO (для сохранения сессии и обратных вызовов).
  ///
  /// [user] — сущность; возвращает [UserProfileDto].
  static UserProfileDto toDto(AppUser user) => UserProfileDto(
    id: user.id,
    email: user.email,
    name: user.name,
    photoUrl: user.photoUrl,
    rating: user.rating,
    notificationsEnabled: user.notificationsEnabled,
  );
}
