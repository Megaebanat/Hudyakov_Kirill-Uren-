import '../../common/logging/app_logger.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/remote_api_data_source.dart';
import '../datasources/session_store.dart';
import '../mappers/error_mapper.dart';
import '../mappers/user_mapper.dart';

/// Реализация [ProfileRepository]: REST API + синхронизация локальной сессии.
///
/// Ответственность (SRP): загрузка и изменение профиля.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class ProfileRepositoryImpl implements ProfileRepository {
  /// Удалённый источник данных.
  final RemoteApiDataSource _api;

  /// Локальное хранилище сессии (кэш профиля пользователя).
  final SessionStore _sessionStore;

  /// Создаёт реализацию.
  ///
  /// [api] — удалённый источник; [sessionStore] — хранилище сессии.
  ProfileRepositoryImpl({required this._api, required this._sessionStore});

  @override
  Future<AppUser> getProfile() async {
    try {
      AppLogger.info(
        'ProfileRepository',
        'Загрузка профиля',
        'Запрос отправлен',
      );
      final dto = await _api.getProfile();
      final user = UserMapper.toEntity(dto);
      await _sessionStore.updateUser(user);
      AppLogger.debug(
        'ProfileRepository',
        'Загрузка профиля',
        'Успех: ${user.email}',
      );
      return user;
    } catch (error, stackTrace) {
      AppLogger.error(
        'ProfileRepository',
        'Загрузка профиля — ошибка',
        error,
        stackTrace,
      );
      throw ErrorMapper.map(error);
    }
  }

  @override
  Future<AppUser> updateProfile({
    String? name,
    String? photoUrl,
    bool? notificationsEnabled,
  }) async {
    try {
      AppLogger.info(
        'ProfileRepository',
        'Изменение профиля',
        'Запрос отправлен',
      );
      final dto = await _api.updateProfile(
        name: name,
        photoUrl: photoUrl,
        notificationsEnabled: notificationsEnabled,
      );
      final user = UserMapper.toEntity(dto);
      await _sessionStore.updateUser(user);
      AppLogger.info(
        'ProfileRepository',
        'Изменение профиля',
        'Успех: ${user.email}',
      );
      return user;
    } catch (error, stackTrace) {
      AppLogger.error(
        'ProfileRepository',
        'Изменение профиля — ошибка',
        error,
        stackTrace,
      );
      throw ErrorMapper.map(error);
    }
  }
}
