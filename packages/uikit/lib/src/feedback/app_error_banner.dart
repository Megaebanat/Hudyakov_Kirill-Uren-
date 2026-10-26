import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Уведомление об ошибке в стиле макета: показывается ровно 5 секунд,
/// закрывается досрочно кнопкой ✕ (принудительное закрытие).
///
/// Используется при ошибках сервера и отсутствии соединения с сетью.
///
/// Ответственность (SRP): отображение ошибок сети пользователю.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppErrorBanner extends StatelessWidget {
  /// Текст ошибки.
  final String message;

  /// Длительность показа (по требованию — 5 секунд).
  final Duration duration;

  /// Создаёт баннер ошибки.
  ///
  /// [message] — текст; [duration] — длительность показа.
  const AppErrorBanner({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 5),
  });

  /// Показывает уведомление об ошибке [message] на 5 секунд.
  ///
  /// [context] — контекст с ScaffoldMessenger; [message] — текст ошибки.
  /// По кнопке ✕ уведомление закрывается принудительно.
  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    // Закрываем предыдущее уведомление, чтобы не было «стопки» ошибок.
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Expanded(child: AppErrorBanner(message: message)),
            // Принудительное закрытие уведомления по кнопке.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => messenger.hideCurrentSnackBar(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _BannerBody(message: message);
}

/// Тело баннера (выделено для чистоты build).
class _BannerBody extends StatelessWidget {
  /// Текст ошибки.
  final String message;

  /// Создаёт тело баннера.
  const _BannerBody({required this.message});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      );
}
