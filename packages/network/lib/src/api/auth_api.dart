import '../dto/auth_dto.dart';
import '../http/http_client.dart';
import '../http/response_parser.dart';

/// Абстракция запросов аутентификации (интерфейс для приложения).
///
/// Ответственность (SRP): операции входа, регистрации и выхода.
/// Приложение зависит только от интерфейса (ISP/DIP), реализацию
/// ([RestAuthApi]) можно заменить без изменения вызывающего кода.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract interface class AuthApi {
  /// Вход по email и паролю.
  ///
  /// [email] — почта; [password] — пароль.
  /// Возвращает токен и профиль; бросает [NetworkException] при ошибке.
  Future<AuthResponseDto> login({required String email, required String password});

  /// Регистрация нового пользователя.
  ///
  /// [email] — почта; [password] — пароль; [name] — отображаемое имя.
  Future<AuthResponseDto> register({
    required String email,
    required String password,
    required String name,
  });

  /// Выход из текущей сессии (инвалидация токена на сервере).
  Future<void> logout();
}

/// Реализация [AuthApi] поверх абстрактного [HttpClient].
///
/// Ответственность (SRP): только эндпоинты аутентификации и их парсинг.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class RestAuthApi implements AuthApi {
  /// Абстрактный HTTP-клиент (базовые методы GET/POST/PUT/DELETE).
  final HttpClient client;

  /// Централизованный парсер ответов (единая обработка ошибок — DRY).
  final ResponseParser parser;

  /// Создаёт API аутентификации.
  ///
  /// [client] — HTTP-клиент; [parser] — парсер ответов.
  RestAuthApi({required this.client, required this.parser});

  @override
  Future<AuthResponseDto> login({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    final json = parser.asMap(
      parser.parse(
        rawBody: response.body,
        statusCode: response.statusCode,
        requestedPath: '/auth/login',
      ),
      '/auth/login',
    );
    return AuthResponseDto.fromJson(json);
  }

  @override
  Future<AuthResponseDto> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await client.post(
      '/auth/register',
      body: {'email': email, 'password': password, 'name': name},
    );
    final json = parser.asMap(
      parser.parse(
        rawBody: response.body,
        statusCode: response.statusCode,
        requestedPath: '/auth/register',
      ),
      '/auth/register',
    );
    return AuthResponseDto.fromJson(json);
  }

  @override
  Future<void> logout() async {
    final response = await client.post('/auth/logout');
    parser.parse(
      rawBody: response.body,
      statusCode: response.statusCode,
      requestedPath: '/auth/logout',
    );
  }
}
