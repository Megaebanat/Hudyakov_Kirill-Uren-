import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../feedback/app_bottom_sheet.dart';

/// Элемент выпадающего селекта.
///
/// Ответственность (SRP): связка «отображаемое имя + значение».
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class SelectItem<T> {
  /// Значение, возвращаемое в onChanged.
  final T value;

  /// Отображаемый текст в списке.
  final String label;

  /// Иконка элемента (опционально).
  final IconData? icon;

  /// Создаёт элемент селекта.
  ///
  /// [value] — значение; [label] — текст; [icon] — иконка.
  const SelectItem({required this.value, required this.label, this.icon});
}

/// Компонент «Селект»: при нажатии открывается BottomSheet с выбором.
///
/// Ответственность (SRP): отображение текущего выбора и открытие списка.
/// Хранение выбранного значения — на вызывающей стороне (value/onChanged).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppSelect<T> extends StatelessWidget {
  /// Текущее выбранное значение (null — ничего не выбрано).
  final T? value;

  /// Доступные элементы.
  final List<SelectItem<T>> items;

  /// Текст-подсказка, пока ничего не выбрано.
  final String hint;

  /// Лейбл над контролом.
  final String? label;

  /// Обработчик выбора (вызывается после закрытия BottomSheet).
  final ValueChanged<T> onChanged;

  /// Доступен ли выбор (false — состояние disabled).
  final bool enabled;

  /// Создаёт селект.
  ///
  /// [value] — текущее значение; [items] — элементы; [hint] — подсказка;
  /// [label] — лейбл; [onChanged] — выбор; [enabled] — доступность.
  const AppSelect({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final selected = _selectedItem();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTypography.label),
          const SizedBox(height: 8),
        ],
        Semantics(
          button: true,
          enabled: enabled,
          label: 'Селект: ${selected?.label ?? hint}',
          child: InkWell(
            onTap: enabled ? () => _openSheet(context) : null,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: enabled ? AppColors.surfaceAlt : AppColors.disabledFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  if (selected?.icon != null) ...[
                    Icon(
                      selected!.icon,
                      size: 20,
                      color: enabled
                          ? AppColors.primary
                          : AppColors.disabledText,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      selected?.label ?? hint,
                      style: AppTypography.bodySmall.copyWith(
                        color: enabled
                            ? (selected == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary)
                            : AppColors.disabledText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: enabled
                        ? AppColors.textSecondary
                        : AppColors.disabledText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Ищет элемент, соответствующий текущему [value].
  ///
  /// Без параметров; null, если значение не найдено среди [items].
  SelectItem<T>? _selectedItem() {
    for (final item in items) {
      if (item.value == value) return item;
    }
    return null;
  }

  /// Открывает BottomSheet с выбором и транслирует выбранное значение.
  ///
  /// [context] — контекст для открытия модального окна.
  void _openSheet(BuildContext context) async {
    final result = await AppBottomSheet.show<SelectItem<T>>(
      context: context,
      title: hint,
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(color: AppColors.outline),
        itemBuilder: (context, index) {
          final item = items[index];
          final isCurrent = item.value == value;
          return ListTile(
            leading: item.icon == null
                ? null
                : Icon(
                    item.icon,
                    color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                  ),
            title: Text(
              item.label,
              style: AppTypography.bodySmall.copyWith(
                color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            trailing: isCurrent
                ? const Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(item),
          );
        },
      ),
    );
    if (result != null) onChanged(result.value);
  }
}
