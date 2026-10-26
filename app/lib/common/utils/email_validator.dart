/// Валидация email по паттерну задания:
/// «name@domainname.ru», где имя и доменное имя может состоять
/// только из маленьких букв и цифр.
///
/// Ответственность (SRP): только проверка корректности email.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class EmailValidator {
  /// Приватный конструктор: утилитарный класс.
  EmailValidator._();

  /// Паттерн: латинские строчные буквы и цифры, домен с точками.
  static final RegExp _pattern = RegExp(r'^[a-z0-9]+@[a-z0-9]+(\.[a-z0-9]+)+$');

  /// Проверяет, соответствует ли [email] паттерну.
  ///
  /// [email] — проверяемая строка; true — адрес корректен.
  static bool isValid(String email) => _pattern.hasMatch(email.trim());

  /// Возвращает текст ошибки для поля или null, если email корректен.
  ///
  /// [email] — проверяемая строка; null — ошибки нет.
  static String? errorText(String email) =>
      isValid(email) ? null : 'Введите корректный email: name@domain.ru';
}
