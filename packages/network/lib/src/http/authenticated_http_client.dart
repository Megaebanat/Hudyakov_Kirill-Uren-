import '../transport/http_request.dart';
import 'http_client.dart';

/// Поставщик токена аутентификации (подписывается приложением).
///
/// Возвращает текущий токен сессии или null, если пользователь не вошёл.
typedef TokenProvider = String? Function();

/// Декоратор [HttpClient], централизованно добавляющий заголовок
/// `Authorization: Bearer <token>` ко **всем** запросам (DRY).
///
/// Паттерн «Декоратор» позволяет не изменять реализации клиентов
/// (DartHttpClient, MockHttpClient и др.) и сохранять заменяемость (OCP).
///
/// Ответственность (SRP): единственная обязанность — аутентификация запросов.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AuthenticatedHttpClient implements HttpClient {
  /// Декорируемый клиент (реальный или тестовый).
  final HttpClient inner;

  /// Источник токена сессии.
  final TokenProvider tokenProvider;

  /// Создаёт декоратор аутентификации.
  ///
  /// [inner] — обёрнутый клиент; [tokenProvider] — провайдер токена.
  AuthenticatedHttpClient({required this.inner, required this.tokenProvider});

  @override
  Future<HttpResponse> get(
    String path, {
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) =>
      inner.get(path, query: query, headers: _withAuth(headers));

  @override
  Future<HttpResponse> post(
    String path, {
    Object? body,
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) =>
      inner.post(path, body: body, query: query, headers: _withAuth(headers));

  @override
  Future<HttpResponse> put(
    String path, {
    Object? body,
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) =>
      inner.put(path, body: body, query: query, headers: _withAuth(headers));

  @override
  Future<HttpResponse> delete(
    String path, {
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) =>
      inner.delete(path, query: query, headers: _withAuth(headers));

  /// Добавляет Authorization к заголовкам [headers], если токен есть.
  ///
  /// [headers] — исходные заголовки; возвращает копию с Authorization.
  Map<String, String> _withAuth(Map<String, String> headers) {
    final token = tokenProvider();
    if (token == null || token.isEmpty) return headers;
    return {...headers, 'Authorization': 'Bearer $token'};
  }
}
