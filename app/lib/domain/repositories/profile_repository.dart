import '../entities/app_user.dart';

/// Абстракция репозитория профиля.
///
/// Ответственность (SRP): получение и изменение профиля игрока.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract interface class ProfileRepository {
  /// Получает профиль текущего пользователя.
  Future<AppUser> getProfile();

  /// Изменяет профиль и синхронизирует локальную сессию.
  ///
  /// [name] — имя (опционально); [photoUrl] — фото (опционально);
  /// [notificationsEnabled] — уведомления (опционально).
  Future<AppUser> updateProfile({
    String? name,
    String? photoUrl,
    bool? notificationsEnabled,
  });
}
