import '../entities/app_user.dart';
import '../repositories/profile_repository.dart';

/// Use case: получение профиля текущего пользователя.
///
/// Ответственность (SRP): единственный сценарий загрузки профиля.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GetProfileUseCase {
  /// Репозиторий профиля (абстракция — DIP).
  final ProfileRepository repository;

  /// Создаёт use case.
  ///
  /// [repository] — репозиторий профиля.
  GetProfileUseCase(this.repository);

  /// Загружает профиль.
  ///
  /// Без параметров; возвращает [AppUser].
  Future<AppUser> call() => repository.getProfile();
}
