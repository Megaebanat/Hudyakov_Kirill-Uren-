import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Тема приложения, собранная из дизайн-токенов UIKit.
///
/// Ответственность (SRP): сборка ThemeData из AppColors/AppTypography.
/// Все экраны используют тему — значения не дублируются в виджетах (DRY).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract final class AppTheme {
  /// Строит тёмную тему приложения.
  ///
  /// Не принимает параметров: все токены берутся из дизайн-токенов библиотеки.
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.onPrimary,
        outline: AppColors.outline,
      ),
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      inputDecorationTheme: _inputDecoration(),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppTypography.h3,
        contentTextStyle: AppTypography.bodySmall,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Переносит стили [AppTypography] в структуру Material [textTheme].
  ///
  /// [base] — базовая текстовая тема платформы; возвращает тему приложения.
  static TextTheme _textTheme(TextTheme base) => base.copyWith(
        displayLarge: AppTypography.display,
        displayMedium: AppTypography.display,
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        titleLarge: AppTypography.h3,
        titleMedium: AppTypography.body,
        titleSmall: AppTypography.bodySmall,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.bodySmall,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.label,
        labelSmall: AppTypography.caption,
      );

  /// Единое оформление полей ввода ( состояния enabled/focused/error/disabled ).
  static InputDecorationTheme _inputDecoration() => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        labelStyle: AppTypography.label,
        errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.disabledFill),
        ),
      );
}
