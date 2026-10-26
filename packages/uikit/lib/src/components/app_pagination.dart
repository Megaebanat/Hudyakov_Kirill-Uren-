import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Компонент пагинации (точки-индикаторы страниц).
///
/// Ответственность (SRP): отображение текущей страницы и запрос перехода.
/// Данные страниц хранятся у вызывающей стороны.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppPagination extends StatelessWidget {
  /// Общее количество страниц.
  final int pageCount;

  /// Индекс текущей страницы (от 0).
  final int currentIndex;

  /// Обработчик перехода на страницу [index].
  final ValueChanged<int> onSelect;

  /// Создаёт пагинацию.
  ///
  /// [pageCount] — страниц; [currentIndex] — текущая; [onSelect] — переход.
  const AppPagination({
    super.key,
    required this.pageCount,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final selected = index == currentIndex;
        return Semantics(
          button: true,
          selected: selected,
          label: 'Страница ${index + 1}',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: selected ? 26 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}
