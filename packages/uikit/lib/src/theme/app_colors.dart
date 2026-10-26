import 'package:flutter/material.dart';

/// Палитра приложения — единственный источник истины для цветов (DRY).
///
/// Все цвета макета определены здесь; компоненты и экраны не объявляют
/// цвета самостоятельно. При изменении дизайна правится только этот файл.
///
/// Ответственность (SRP): только описание палитры.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract final class AppColors {
  // --- Основные поверхности -------------------------------------------------
  /// Фон приложения (самый тёмный).
  static const Color background = Color(0xFF0F1216);

  /// Фон карточек и панелей.
  static const Color surface = Color(0xFF181C22);

  /// Поверхность второго уровня (поля ввода, чипы).
  static const Color surfaceAlt = Color(0xFF22272F);

  /// Обводка/разделители.
  static const Color outline = Color(0xFF2E3540);

  // --- Акценты --------------------------------------------------------------
  /// Основной акцент (CTA-кнопки, выделение).
  static const Color primary = Color(0xFFFF6B35);

  /// Акцент при нажатии (затемнённый primary).
  static const Color primaryPressed = Color(0xFFE55A28);

  /// Вторичный акцент (категория «Круг», ссылки).
  static const Color secondary = Color(0xFF3D8BFF);

  /// Категория «Картинка» / негативная индикация выделения.
  static const Color accentRed = Color(0xFFE74C3C);

  // --- Статусы --------------------------------------------------------------
  /// Успех.
  static const Color success = Color(0xFF2ECC71);

  /// Ошибка.
  static const Color error = Color(0xFFE74C3C);

  /// Предупреждение.
  static const Color warning = Color(0xFFF1C40F);

  // --- Текст ----------------------------------------------------------------
  /// Основной текст.
  static const Color textPrimary = Color(0xFFF5F7FA);

  /// Вторичный текст (подписи, плейсхолдеры).
  static const Color textSecondary = Color(0xFF9AA4B2);

  /// Текст на акцентной кнопке.
  static const Color onPrimary = Color(0xFFFFFFFF);

  // --- Состояния компонентов ------------------------------------------------
  /// Отключённое состояние (disabled) — заливка.
  static const Color disabledFill = Color(0xFF2A2F37);

  /// Отключённый текст.
  static const Color disabledText = Color(0xFF6B7280);

  /// Затемнение при нажатии (overlay).
  static const Color pressedOverlay = Color(0x33FFFFFF);

  /// Оверлей затемнения под модальными окнами/меню.
  static const Color scrim = Color(0x99000000);

  /// Прозрачный цвет (для InkWell-подложек).
  static const Color transparent = Colors.transparent;
}
