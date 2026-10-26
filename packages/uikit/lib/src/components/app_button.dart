import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Варианты кнопки UIKit.
enum AppButtonVariant {
  /// Основная CTA-кнопка (заливка акцентом).
  primary,

  /// Вторичная кнопка (обводка).
  secondary,

  /// Текстовая/призрачная кнопка (без заливки).
  ghost,
}

/// Кнопка UIKit со всеми состояниями макета: обычная, нажатая (pressed),
/// отключённая (disabled) и загрузка (loading).
///
/// Ответственность (SRP): отображение кнопки и трансляция нажатий.
/// Варианты/состояния задаются параметрами — открытость расширению (OCP),
/// дочерние вариации не дублируют код базовой кнопки (DRY).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppButton extends StatelessWidget {
  /// Текст кнопки.
  final String label;

  /// Обработчик нажатия; null — кнопка в состоянии disabled.
  final VoidCallback? onPressed;

  /// Визуальный вариант кнопки.
  final AppButtonVariant variant;

  /// Состояние загрузки (показывает индикатор вместо текста).
  final bool loading;

  /// Иконка перед текстом.
  final IconData? icon;

  /// Растянуть на всю ширину родителя.
  final bool expand;

  /// Высота кнопки.
  final double height;

  /// Создаёт кнопку.
  ///
  /// [label] — текст; [onPressed] — обработчик (null = disabled);
  /// [variant] — вариант; [loading] — загрузка; [icon] — иконка;
  /// [expand] — растянуть; [height] — высота.
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.expand = true,
    this.height = 56,
  });

  /// Кнопка в состоянии disabled (семантика для тестов и аналитики).
  bool get isDisabled => onPressed == null || loading;

  @override
  Widget build(BuildContext context) {
    final colors = _colors();
    final child = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colors.foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: colors.foreground),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTypography.button.copyWith(color: colors.foreground)),
            ],
          );

    final button = Material(
      color: colors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        highlightColor: AppColors.pressedOverlay,
        splashColor: AppColors.pressedOverlay,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: colors.border == null
                ? null
                : Border.all(color: colors.border!, width: 1.5),
          ),
          child: child,
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  /// Определяет цвета по варианту и состоянию (нажатие отслеживается InkWell).
  _ButtonColors _colors() {
    if (isDisabled) {
      return const _ButtonColors(
        background: AppColors.disabledFill,
        foreground: AppColors.disabledText,
      );
    }
    return switch (variant) {
      AppButtonVariant.primary => const _ButtonColors(
          background: AppColors.primary,
          foreground: AppColors.onPrimary,
        ),
      AppButtonVariant.secondary => const _ButtonColors(
          background: AppColors.transparent,
          foreground: AppColors.textPrimary,
          border: AppColors.outline,
        ),
      AppButtonVariant.ghost => const _ButtonColors(
          background: AppColors.transparent,
          foreground: AppColors.primary,
        ),
    };
  }
}

/// Цветовая схема состояний кнопки (внутренняя модель).
class _ButtonColors {
  /// Заливка.
  final Color background;

  /// Цвет содержимого.
  final Color foreground;

  /// Цвет обводки (опционально).
  final Color? border;

  /// Создаёт цветовую схему.
  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.border,
  });
}
