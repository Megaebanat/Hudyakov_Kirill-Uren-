/// Иерархия ошибок сетевого слоя.
///
/// Каждая ошибочная ситуация моделируется отдельным типом, чтобы вызывающий
/// код мог точно обработать причину (интернет недоступен / таймаут /
/// ошибка сервера / бизнес-ошибка API) и показать корректное уведомление.
///
/// Ответственность (SRP): описание ошибок сети и их пользовательских сообщений.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
library;

/// Базовый тип всех ошибок сетевого слоя.
abstract class NetworkException implements Exception {
  /// Человекочитаемое сообщение для показа пользователю.
  final String message;

  /// Создаёт ошибку сети с сообщением [message].
  const NetworkException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Отсутствие соединения с сетью Интернет.
class ConnectionException extends NetworkException {
  /// Создаёт ошибку отсутствия соединения.
  const ConnectionException([
    super.message = 'Нет соединения с сетью Интернет',
  ]);
}

/// Превышено время ожидания ответа сервера.
class TimeoutException extends NetworkException {
  /// Создаёт ошибку таймаута.
  const TimeoutException([
    super.message = 'Сервер не отвечает: превышено время ожидания',
  ]);
}

/// Ошибка 5xx на стороне сервера.
class ServerException extends NetworkException {
  /// Код HTTP-статуса.
  final int statusCode;

  /// Путь запроса, на котором произошла ошибка.
  final String path;

  /// Создаёт ошибку сервера.
  ///
  /// [statusCode] — статус; [message] — сообщение; [path] — путь запроса.
  ServerException(this.statusCode, String message, this.path)
      : super(message.isEmpty ? 'Ошибка сервера (код $statusCode)' : message);
}

/// Бизнес-ошибка API (4xx с сообщением в теле ответа).
class ApiErrorException extends NetworkException {
  /// Код HTTP-статуса.
  final int statusCode;

  /// Создаёт ошибку API.
  ///
  /// [statusCode] — статус; [message] — сообщение от сервера.
  ApiErrorException(this.statusCode, String message)
      : super(message.isEmpty ? 'Ошибка запроса (код $statusCode)' : message);
}

/// Ошибка аутентификации (401/403).
class UnauthorizedException extends NetworkException {
  /// Создаёт ошибку авторизации.
  const UnauthorizedException([String message = 'Требуется авторизация'])
      : super(message);
}

/// Ресурс не найден (404).
class NotFoundException extends NetworkException {
  /// Создаёт ошибку «не найдено».
  const NotFoundException([super.message = 'Данные не найдены']);
}

/// Ошибка формата данных (неожиданный JSON).
class SerializationException extends NetworkException {
  /// Создаёт ошибку сериализации.
  const SerializationException([super.message = 'Ошибка разбора данных']);
}
