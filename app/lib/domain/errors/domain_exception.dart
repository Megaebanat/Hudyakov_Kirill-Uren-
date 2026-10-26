/// Доменные ошибки — ошибки предметной области, не зависящие от сети и UI.
///
/// Слой data преобразует [NetworkException] в [DomainException], чтобы
/// presentation не знал о деталях транспорта (граница слоёв).
///
/// Ответственность (SRP): описание бизнес-ошибок.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
library;

/// Базовая доменная ошибка с сообщением для пользователя.
class DomainException implements Exception {
  /// Человекочитаемое сообщение.
  final String message;

  /// Создаёт доменную ошибку.
  ///
  /// [message] — сообщение для пользователя.
  const DomainException(this.message);

  @override
  String toString() => 'DomainException: $message';
}

/// Ошибка валидации ввода данных (доменная).
class ValidationException extends DomainException {
  /// Создаёт ошибку валидации.
  ///
  /// [message] — описание нарушенного правила.
  const ValidationException(super.message);
}
