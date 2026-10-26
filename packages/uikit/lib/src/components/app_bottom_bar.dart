import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Пункт нижней навигации.
///
/// Ответственность (SRP): описание одного пункта (иконка + подпись).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppBottomBarItem {
  /// Иконка пункта.
  final IconData icon;

  /// Подпись пункта.
  final String label;

  /// Создаёт пункт навигации.
  ///
  /// [icon] — иконка; [label] — подпись.
  const AppBottomBarItem({required this.icon, required this.label});
}

/// Нижняя панель навигации с центральной акцентной кнопкой.
///
/// Центральная кнопка, как на макете, вынесена из пунктов и имеет
/// увеличенный акцентный «выход» за границы панели.
///
/// Ответственность (SRP): навигация по разделам и вызов центрального действия.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppBottomBar extends StatelessWidget {
  /// Пункты слева и справа от центральной кнопки (чётное деление).
  final List<AppBottomBarItem> items;

  /// Индекс активного пункта.
  final int currentIndex;

  /// Обработчик выбора пункта [index].
  final ValueChanged<int> onChanged;

  /// Иконка центральной кнопки.
  final IconData centerIcon;

  /// Обработчик центральной кнопки (например, переход к Schedule Game).
  final VoidCallback onCenterPressed;

  /// Подпись центральной кнопки (для семантики).
  final String centerLabel;

  /// Создаёт нижнюю панель.
  ///
  /// [items] — пункты; [currentIndex] — активный; [onChanged] — выбор;
  /// [centerIcon] — иконка центра; [onCenterPressed] — действие центра;
  /// [centerLabel] — подпись центра для скринридеров.
  const AppBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    required this.onCenterPressed,
    this.centerIcon = Icons.add_rounded,
    this.centerLabel = 'Создать игру',
  });

  @override
  Widget build(BuildContext context) {
    final half = items.length ~/ 2;
    final left = items.sublist(0, half);
    final right = items.sublist(half);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < left.length; i++) _item(left[i], i),
            const Spacer(),
            _centerButton(),
            const Spacer(),
            for (var i = 0; i < right.length; i++)
              _item(right[i], half + i),
          ],
        ),
      ),
    );
  }

  /// Собирает обычный пункт навигации.
  ///
  /// [item] — пункт; [index] — его индекс.
  Widget _item(AppBottomBarItem item, int index) {
    final selected = index == currentIndex;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: () => onChanged(index),
        borderRadius: BorderRadius.circular(12),
        highlightColor: AppColors.pressedOverlay,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 24,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: AppTypography.caption.copyWith(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Центральная акцентная кнопка с «выходом» за верхний край панели.
  Widget _centerButton() => Semantics(
        button: true,
        label: centerLabel,
        child: GestureDetector(
          onTap: onCenterPressed,
          child: Container(
            width: 60,
            height: 60,
            margin: const EdgeInsets.only(top: 26),
            transform: Matrix4.translationValues(0, -18, 0),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x66FF6B35),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(centerIcon, color: AppColors.onPrimary, size: 30),
          ),
        ),
      );
}
