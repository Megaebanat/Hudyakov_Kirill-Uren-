/// Модель HTTP-запроса, не привязанная к конкретной транспортной библиотеке.
///
/// Ответственность (SRP): описание параметров одного запроса (DTO транспорта).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class HttpRequest {
  /// HTTP-метод (GET, POST, PUT, DELETE).
  final String method;

  /// Относительный путь эндпоинта (например, `/auth/login`).
  final String path;

  /// Заголовки запроса (наследуют дефолтные из [ApiConfig]).
  final Map<String, String> headers;

  /// Параметры строки запроса.
  final Map<String, String> query;

  /// Тело запроса (будет сериализовано в JSON).
  final Object? body;

  /// Создаёт HTTP-запрос.
  ///
  /// [method] — HTTP-метод; [path] — путь эндпоинта;
  /// [headers] — заголовки; [query] — query-параметры; [body] — тело (JSON).
  const HttpRequest({
    required this.method,
    required this.path,
    this.headers = const {},
    this.query = const {},
    this.body,
  });
}

/// Модель HTTP-ответа транспортного уровня.
///
/// Ответственность (SRP): перенос сырого ответа сервера без интерпретации.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class HttpResponse {
  /// Код статуса HTTP.
  final int statusCode;

  /// Заголовки ответа.
  final Map<String, String> headers;

  /// Тело ответа в текстовом виде (JSON-строка).
  final String body;

  /// Создаёт HTTP-ответ.
  ///
  /// [statusCode] — код статуса; [headers] — заголовки; [body] — текст тела.
  const HttpResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
  });

  /// Успешный статус (2xx).
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
