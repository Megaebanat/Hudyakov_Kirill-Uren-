import '../../common/logging/app_logger.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote_api_data_source.dart';
import '../datasources/session_store.dart';
import '../mappers/error_mapper.dart';
import '../mappers/user_mapper.dart';

/// Реализация [AuthRepository]: REST API + локальное сохранение сессии.
///
/// Ответственность (SRP): выполнение сценариев входа/регистрации/выхода
/// и синхронизация локальной сессии.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AuthRepositoryImpl implements AuthRepository {
  /// Удалённый источник данных (через абстракцию библиотеки сети).
  final RemoteApiDataSource _api;

  /// Локальное хранилище сессии.
  final SessionStore _sessionStore;

  /// Создаёт реализацию.
  ///
  /// [api] — удалённый источник; [sessionStore] — хранилище сессии.
  AuthRepositoryImpl({required this._api, required this._sessionStore});

  @override
  Future<Session> signIn({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('AuthRepository', 'Вход пользователя', email);
      final dto = await _api.login(email, password);
      final session = Session(
        token: dto.token,
        user: UserMapper.toEntity(dto.user),
      );
      await _sessionStore.save(session);
      AppLogger.info(
        'AuthRepository',
        'Авторизация',
        'Успех для пользователя $email',
      );
      return session;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AuthRepository',
        'Авторизация — ошибка',
        error,
        stackTrace,
      );
      throw ErrorMapper.map(error);
    }
  }

  @override
  Future<Session> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      AppLogger.info('AuthRepository', 'Регистрация пользователя', email);
      final dto = await _api.register(
        email: email,
        password: password,
        name: name,
      );
      final session = Session(
        token: dto.token,
        user: UserMapper.toEntity(dto.user),
      );
      await _sessionStore.save(session);
      AppLogger.info(
        'AuthRepository',
        'Регистрация',
        'Успех для пользователя $email',
      );
      return session;
    } catch (error, stackTrace) {
      AppLogger.error(
        'AuthRepository',
        'Регистрация — ошибка',
        error,
        stackTrace,
      );
      throw ErrorMapper.map(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      AppLogger.info('AuthRepository', 'Выход из аккаунта', 'Начало');
      await _api.logout();
      AppLogger.debug('AuthRepository', 'Выход из аккаунта', 'Сессия закрыта');
    } catch (error, stackTrace) {
      // Даже при ошибке сервера локальную сессию закрываем обязательно.
      AppLogger.error(
        'AuthRepository',
        'Выход — ошибка сервера',
        error,
        stackTrace,
      );
    } finally {
      await _sessionStore.clear();
      AppLogger.info(
        'AuthRepository',
        'Выход из аккаунта',
        'Локальная сессия очищена',
      );
    }
  }
}
