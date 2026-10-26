/// Единая точка конфигурации сетевого слоя (DRY).
///
/// Базовый URL, таймауты и заголовки по умолчанию определяются **только здесь**
/// и больше нигде не дублируются.
///
/// Ответственность (SRP): хранение и валидация параметров подключения к API.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class ApiConfig {
  /// Базовый URL REST API (например, `https://api.example.ru`).
  final String baseUrl;

  /// Максимальное время на установку соединения.
  final Duration connectTimeout;

  /// Максимальное время ожидания ответа от сервера.
  final Duration receiveTimeout;

  /// Заголовки, добавляемые к каждому запросу.
  final Map<String, String> defaultHeaders;

  /// Создаёт конфигурацию API.
  ///
  /// [baseUrl] — базовый адрес сервера (обязателен);
  /// [connectTimeout] — таймаут соединения, по умолчанию 10 секунд;
  /// [receiveTimeout] — таймаут ответа, по умолчанию 20 секунд;
  /// [defaultHeaders] — общие заголовки запросов.
  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 20),
    this.defaultHeaders = const {'Content-Type': 'application/json'},
  });
}
