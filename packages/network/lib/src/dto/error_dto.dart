/// DTO ошибки, возвращаемой сервером.
///
/// Формат тела ошибки: `{"error": {"code": "...", "message": "..."}}`
/// либо `{"message": "..."}` (оба варианта поддерживаются).
///
/// Ответственность (SRP): приведение ошибок сервера к единому виду (DRY).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class ApiErrorDto {
  /// Машинный код ошибки (например, `invalid_credentials`).
  final String code;

  /// Человекочитаемое сообщение.
  final String message;

  /// Создаёт DTO ошибки.
  ///
  /// [code] — машинный код; [message] — сообщение для пользователя.
  const ApiErrorDto({required this.code, required this.message});

  /// Разбирает тело ответа [json] (может быть null или произвольной формы).
  ///
  /// [json] — декодированный JSON ответа.
  factory ApiErrorDto.fromJson(Object? json) {
    if (json is Map<String, Object?>) {
      final nested = json['error'];
      if (nested is Map<String, Object?>) {
        return ApiErrorDto(
          code: '${nested['code'] ?? 'unknown'}',
          message: '${nested['message'] ?? json['message'] ?? 'Ошибка запроса'}',
        );
      }
      final message = json['message'] ?? json['detail'];
      if (message != null) {
        return ApiErrorDto(code: 'unknown', message: '$message');
      }
    }
    if (json is String && json.isNotEmpty) {
      return ApiErrorDto(code: 'unknown', message: json);
    }
    return const ApiErrorDto(code: 'unknown', message: 'Неизвестная ошибка');
  }

  /// Сериализует DTO в JSON (для тестов и мока).
  Map<String, Object?> toJson() => {'code': code, 'message': message};
}
