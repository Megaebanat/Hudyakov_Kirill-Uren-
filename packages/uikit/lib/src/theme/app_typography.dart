import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Типографика приложения — единственный источник истины для текста (DRY).
///
/// Шрифт Inter соответствует макету Figma; системные аналоги не используются.
/// Размеры зафиксированы значениями из дизайн-системы, при изменении размера
/// экрана текст переносится или обрезается в троеточие, но не обрезается
/// блоком по высоте/ширине.
///
/// Ответственность (SRP): только текстовые стили.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract final class AppTypography {
  /// Имя гарнитуры из assets/fonts.
  static const String fontFamily = 'Inter';

  /// Крупный заголовок: 32 / 38, weight 700.
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Заголовок 1 уровня: 28 / 34, weight 700.
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Заголовок 2 уровня: 24 / 30, weight 600.
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Заголовок 3 уровня: 20 / 26, weight 600.
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Основной текст: 16 / 24, weight 500.
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Уменьшенный текст: 14 / 20, weight 500.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// Подпись/лейбл: 12 / 16, weight 600, uppercase-ready.
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  /// Мелкая подпись: 10 / 14, weight 500.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Кнопка: 16 / 20, weight 600.
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
  );
}
