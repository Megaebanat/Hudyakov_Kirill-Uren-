import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Единая обёртка над модальным нижним листом (стиль макета).
///
/// Ответственность (SRP): открытие/закрытие BottomSheet с общими параметрами.
/// Все нижние листы приложения проходят через этот класс (DRY).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppBottomSheet {
  /// Приватный конструктор: класс содержит только статические методы.
  AppBottomSheet._();

  /// Открывает BottomSheet и возвращает выбранный результат (или null).
  ///
  /// [context] — контекст; [title] — заголовок сверху (опционально);
  /// [child] — содержимое листа; [dismissible] — закрытие тапом на подложку.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    bool dismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: dismissible,
      enableDrag: dismissible,
      backgroundColor: AppColors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Индикатор-«ручка» свайпа.
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (title != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Text(
                    title,
                    style: AppTypography.h3,
                    textAlign: TextAlign.center,
                  ),
                ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
