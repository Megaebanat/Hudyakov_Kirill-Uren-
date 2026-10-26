import '../entities/app_user.dart';
import '../errors/domain_exception.dart';
import '../repositories/profile_repository.dart';

/// Use case: изменение профиля (имя, фото, настройка уведомлений).
///
/// Ответственность (SRP): валидация и координация изменения профиля.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class UpdateProfileUseCase {
  /// Репозиторий профиля (абстракция — DIP).
  final ProfileRepository repository;

  /// Создаёт use case.
  ///
  /// [repository] — репозиторий профиля.
  UpdateProfileUseCase(this.repository);

  /// Применяет изменения профиля.
  ///
  /// [name] — новое имя; [photoUrl] — URL фото;
  /// [notificationsEnabled] — флаг уведомлений; возвращает обновлённый [AppUser].
  /// Бросает [ValidationException], если имя пустое при передаче.
  Future<AppUser> call({
    String? name,
    String? photoUrl,
    bool? notificationsEnabled,
  }) async {
    if (name != null && name.trim().isEmpty) {
      throw const ValidationException('Имя не может быть пустым');
    }
    return repository.updateProfile(
      name: name?.trim(),
      photoUrl: photoUrl,
      notificationsEnabled: notificationsEnabled,
    );
  }
}
