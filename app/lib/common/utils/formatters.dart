/// Форматирование данных для отображения (даты, время, длительность).
///
/// Ответственность (SRP): только представление данных текстом.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class Formatters {
  /// Приватный конструктор: утилитарный класс.
  Formatters._();

  /// Разбирает дату из ISO-8601 строки сервера.
  ///
  /// [raw] — строка сервера; [fallback] — значение при ошибке разбора.
  static DateTime parseServerDate(String raw, {DateTime? fallback}) =>
      DateTime.tryParse(raw) ?? fallback ?? DateTime.now();

  /// Форматирует дату игры: «Сегодня, 18:00», «Завтра, 18:00», «12.01, 18:00».
  ///
  /// [date] — дата игры; [now] — текущий момент (для тестов подменяемый).
  static String gameDateTime(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(current.year, current.month, current.day);
    final tomorrow = today.add(const Duration(days: 1));
    if (day == today) return 'Сегодня, $time';
    if (day == tomorrow) return 'Завтра, $time';
    final dayOfMonth = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$dayOfMonth.$month, $time';
  }

  /// Форматирует длительность как MM:SS.
  ///
  /// [duration] — длительность; возвращает строку «MM:SS».
  static String mmss(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
