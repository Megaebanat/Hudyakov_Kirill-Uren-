import 'dart:convert';

import '../transport/http_request.dart';
import '../transport/http_transport.dart';

/// Абстрактный HTTP-клиент библиотеки — **уровень абстракции** для приложения.
///
/// Приложение (и его тесты) зависят только от этого интерфейса, поэтому
/// реализацию ([DartHttpClient]) можно заменить на любую другую
/// (DioClient, FetchClient, URLSession) без изменения вызывающего кода (DIP).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract interface class HttpClient {
  /// Выполняет GET-запрос к [path] с query-параметрами [query].
  ///
  /// [path] — относительный путь эндпоинта; [query] — параметры строки;
  /// [headers] — дополнительные заголовки поверх базовых.
  Future<HttpResponse> get(
    String path, {
    Map<String, String> query,
    Map<String, String> headers,
  });

  /// Выполняет POST-запрос к [path] с телом [body] (JSON-объект или список).
  ///
  /// [path] — путь эндпоинта; [body] — тело запроса; [query] — query-параметры;
  /// [headers] — дополнительные заголовки.
  Future<HttpResponse> post(
    String path, {
    Object? body,
    Map<String, String> query,
    Map<String, String> headers,
  });

  /// Выполняет PUT-запрос к [path] с телом [body].
  ///
  /// [path] — путь эндпоинта; [body] — тело запроса; [query] — query-параметры;
  /// [headers] — дополнительные заголовки.
  Future<HttpResponse> put(
    String path, {
    Object? body,
    Map<String, String> query,
    Map<String, String> headers,
  });

  /// Выполняет DELETE-запрос к [path].
  ///
  /// [path] — путь эндпоинта; [query] — query-параметры;
  /// [headers] — дополнительные заголовки.
  Future<HttpResponse> delete(
    String path, {
    Map<String, String> query,
    Map<String, String> headers,
  });
}

/// Конкретная реализация [HttpClient] поверх [HttpTransport] (dart:io).
///
/// Ответственность (SRP): сборка базовых HTTP-методов (GET, POST, PUT, DELETE)
/// в одном месте — переиспользование логики запросов (DRY).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class DartHttpClient implements HttpClient {
  /// Транспорт, реально отправляющий запросы.
  final HttpTransport _transport;

  /// Базовый адрес API (единственный источник истины — [ApiConfig]).
  final String baseUrl;

  /// Заголовки, общие для всех запросов.
  final Map<String, String> _defaultHeaders;

  /// Создаёт клиент поверх транспорта.
  ///
  /// [transport] — транспортный уровень; [baseUrl] — базовый URL API;
  /// [defaultHeaders] — общие заголовки.
  DartHttpClient({
    required HttpTransport transport,
    required this.baseUrl,
    Map<String, String> defaultHeaders = const {'Content-Type': 'application/json'},
  })  : _transport = transport,
        _defaultHeaders = defaultHeaders;

  @override
  Future<HttpResponse> get(
    String path, {
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) =>
      _send('GET', path, query: query, headers: headers);

  @override
  Future<HttpResponse> post(
    String path, {
    Object? body,
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) =>
      _send('POST', path, body: body, query: query, headers: headers);

  @override
  Future<HttpResponse> put(
    String path, {
    Object? body,
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) =>
      _send('PUT', path, body: body, query: query, headers: headers);

  @override
  Future<HttpResponse> delete(
    String path, {
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) =>
      _send('DELETE', path, query: query, headers: headers);

  /// Фабрика запроса: единая точка сборки запроса с базовыми параметрами (DRY).
  ///
  /// [method] — HTTP-метод; [path] — путь; [body] — тело; [query] — query;
  /// [headers] — дополнительные заголовки поверх базовых.
  Future<HttpResponse> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) {
    final url = Uri.parse(baseUrl).replace(path: path);
    final fullUrl = url.hasQuery || query.isEmpty
        ? url.toString()
        : url.replace(queryParameters: query).toString();

    return _transport.send(
      HttpRequest(
        method: method,
        path: fullUrl,
        headers: {..._defaultHeaders, ...headers},
        query: query,
        body: body,
      ),
    );
  }
}

/// Сериализует [value] в JSON-строку для тела запроса.
///
/// [value] — объект или список; возвращает JSON-строку.
String encodeJson(Object? value) => jsonEncode(value);
