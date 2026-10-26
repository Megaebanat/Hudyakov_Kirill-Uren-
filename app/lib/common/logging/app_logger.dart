import 'package:flutter/foundation.dart';

/// Уровни логирования приложения.
enum AppLogLevel {
  /// Техническая информация для отладки.
  debug,

  /// Ключевые события жизненного цикла.
  info,

  /// Исключения и сбои.
  error,
}

/// Централизованный логгер приложения.
///
/// Формат сообщения (по требованию): `[Тег_компонента]: Событие — Детали`.
/// Пример: `[AuthViewModel]: Авторизация — Успех для пользователя user@mail.com`.
///
/// Уровни: DEBUG — технические данные, INFO — события жизненного цикла и
/// пользовательских действий, ERROR — исключения и сбои.
///
/// Ответственность (SRP): формирование и вывод логов.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppLogger {
  /// Приватный конструктор: только статические методы.
  AppLogger._();

  /// Подменный обработчик вывода (используется в тестах).
  static void Function(String line, AppLogLevel level)? sink;

  /// Последняя записанная строка (удобно для тестов).
  static String? lastLine;

  /// Уровень последней записи.
  static AppLogLevel? lastLevel;

  /// Запись уровня DEBUG: содержимое данных, результаты вычислений.
  ///
  /// [tag] — тег компонента; [event] — событие; [details] — детали.
  static void debug(String tag, String event, [String details = '']) =>
      _write(AppLogLevel.debug, tag, event, details);

  /// Запись уровня INFO: жизненный цикл, отправка запросов, нажатия.
  ///
  /// [tag] — тег компонента; [event] — событие; [details] — детали.
  static void info(String tag, String event, [String details = '']) =>
      _write(AppLogLevel.info, tag, event, details);

  /// Запись уровня ERROR: исключения и сбои.
  ///
  /// [tag] — тег компонента; [event] — событие; [error] — объект ошибки;
  /// [stackTrace] — стек вызовов (опционально).
  static void error(
    String tag,
    String event, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final details = error == null ? '' : '$error';
    _write(AppLogLevel.error, tag, event, details);
    assert(() {
      if (stackTrace != null) debugPrint('  $stackTrace');
      return true;
    }());
  }

  /// Собирает строку лога в едином формате.
  ///
  /// [tag] — тег; [event] — событие; [details] — детали; возвращает строку.
  static String format(String tag, String event, String details) =>
      details.isEmpty ? '[$tag]: $event' : '[$tag]: $event — $details';

  /// Выводит запись через [sink] либо в консоль (debugPrint).
  ///
  /// [level] — уровень; [tag] — тег; [event] — событие; [details] — детали.
  static void _write(
    AppLogLevel level,
    String tag,
    String event,
    String details,
  ) {
    final line = format(tag, event, details);
    lastLine = line;
    lastLevel = level;
    final handler = sink;
    if (handler != null) {
      handler(line, level);
    } else {
      debugPrint(line);
    }
  }
}
