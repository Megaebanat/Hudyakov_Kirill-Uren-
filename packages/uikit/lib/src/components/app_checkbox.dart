import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Компонент чекбокса (галка) со всеми состояниями: выключен, включён,
/// недоступен; подпись опциональна.
///
/// Ответственность (SRP): отображение булева флага и трансляция изменений.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppCheckbox extends StatelessWidget {
  /// Текущее значение.
  final bool value;

  /// Обработчик переключения.
  final ValueChanged<bool> onChanged;

  /// Подпись справа от галки.
  final String? label;

  /// Доступность (false — состояние disabled).
  final bool enabled;

  /// Создаёт чекбокс.
  ///
  /// [value] — значение; [onChanged] — переключение; [label] — подпись;
  /// [enabled] — доступность.
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? (value ? AppColors.primary : AppColors.textSecondary)
        : AppColors.disabledText;

    return Semantics(
      checked: value,
      enabled: enabled,
      label: label ?? 'Чекбокс',
      child: InkWell(
        onTap: enabled ? () => onChanged(!value) : null,
        borderRadius: BorderRadius.circular(8),
        highlightColor: AppColors.pressedOverlay,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value && enabled ? AppColors.primary : AppColors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: color,
                    width: value ? 0 : 2,
                  ),
                ),
                child: value && enabled
                    ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColors.onPrimary,
                      )
                    : null,
              ),
              if (label != null) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label!,
                    style: AppTypography.bodySmall.copyWith(
                      color: enabled
                          ? AppColors.textPrimary
                          : AppColors.disabledText,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
