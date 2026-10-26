import 'dart:convert';

import '../dto/error_dto.dart';
import '../errors/network_exception.dart';
import '../transport/http_request.dart';

/// Централизованный разбор ответов сервера (единый формат ответов — DRY).
///
/// Ответственность (SRP): превращение сырого [HttpResponse]-подобного тела
/// в JSON-объект либо в типизированную ошибку. Все эндпоинты проходят
/// через этот класс — обработка ошибок не дублируется в каждом запросе.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class ResponseParser {
  /// Разбирает тело ответа [rawBody] со статусом [statusCode].
  ///
  /// Успешный статус (2xx) — возвращает декодированный JSON (Map/List);
  /// в противном случае брасывает соответствующее исключение
  /// [ServerException] / [ApiErrorException].
  ///
  /// [rawBody] — текст тела; [statusCode] — код статуса;
  /// [requestedPath] — путь запроса (для сообщения об ошибке).
  Object? parse({
    required String rawBody,
    required int statusCode,
    required String requestedPath,
  }) {
    Object? decoded;
    if (rawBody.isNotEmpty) {
      try {
        decoded = jsonDecode(rawBody);
      } on FormatException {
        if (statusCode >= 200 && statusCode < 300) {
          // Сервер вернул не JSON при 2xx — это ошибка сериализации.
          throw SerializationException(
            'Некорректный JSON в ответе на $requestedPath',
          );
        }
        decoded = null;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    // Ошибка уровня сервера: извлекаем человекочитаемое сообщение.
    final error = ApiErrorDto.fromJson(decoded);
    if (statusCode == 401 || statusCode == 403) {
      throw UnauthorizedException(error.message);
    }
    if (statusCode == 404) {
      throw NotFoundException(error.message);
    }
    if (statusCode >= 500) {
      throw ServerException(statusCode, error.message, requestedPath);
    }
    throw ApiErrorException(statusCode, error.message);
  }

  /// Возвращает JSON-объект из [decoded] как Map либо бросает
  /// [SerializationException], если формат неожиданный.
  ///
  /// [decoded] — декодированный JSON; [requestedPath] — путь запроса.
  Map<String, Object?> asMap(Object? decoded, String requestedPath) {
    if (decoded is Map<String, Object?>) return decoded;
    throw SerializationException('Неожиданный формат ответа: $requestedPath');
  }

  /// Возвращает JSON-список из [decoded] либо бросает
  /// [SerializationException].
  ///
  /// [decoded] — декодированный JSON; [requestedPath] — путь запроса.
  List<Object?> asList(Object? decoded, String requestedPath) {
    if (decoded is List<Object?>) return decoded;
    throw SerializationException('Неожиданный формат списка: $requestedPath');
  }
}
