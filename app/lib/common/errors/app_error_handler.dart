import 'package:flutter/foundation.dart';

/// Глобальный диспетчер ошибок: экраны сообщают об ошибке без знания
/// контекста, корневое приложение показывает уведомление [AppErrorBanner]
/// (5 секунд + закрытие кнопкой ✕).
///
/// Ответственность (SRP): единственная задача — передать текст ошибки
/// к корневому ScaffoldMessenger.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppErrorHandler {
  /// Приватный конструктор: только статические члены.
  AppErrorHandler._();

  /// Текущая ожидающая показа ошибка (null — показывать нечего).
  static final ValueNotifier<String?> message = ValueNotifier<String?>(null);

  /// Сообщает об ошибке [text] для показа пользователю.
  ///
  /// [text] — текст ошибки (перезаписывает предыдущую непоказанную).
  static void report(String text) {
    debugPrint('[AppErrorHandler]: Ошибка — $text');
    message.value = text;
  }

  /// Поглощает ошибку после показа.
  ///
  /// Без параметров; сбрасывает ожидающее значение в null.
  static void consume() => message.value = null;
}
