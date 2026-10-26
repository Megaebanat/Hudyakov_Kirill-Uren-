import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../../common/logging/app_logger.dart';

/// Верхняя панель экранов приложения (тёмная, единый стиль).
///
/// Ответственность (SRP): отображение заголовка, кнопки «назад» и действий.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class ScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Заголовок панели.
  final String title;

  /// Показывать ли кнопку «назад» (по умолчанию — да).
  final bool showBack;

  /// Правые элементы панели (кнопки действий).
  final List<Widget> actions;

  /// Создаёт панель экрана.
  ///
  /// [title] — заголовок; [showBack] — кнопка «назад»; [actions] — действия.
  const ScreenAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.transparent,
      elevation: 0,
      automaticallyImplyLeading: showBack,
      leading: showBack ? const AppBackButton() : null,
      title: Text(title, style: AppTypography.h3),
      actions: actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.outline),
      ),
    );
  }
}

/// Кнопка «назад» с фиксацией нажатия в лог (INFO).
///
/// Ответственность (SRP): логирование и выполнение возврата.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppBackButton extends StatelessWidget {
  /// Создаёт кнопку «назад».
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Назад',
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      color: AppColors.textPrimary,
      onPressed: () {
        AppLogger.info('Navigation', 'Нажатие кнопки', '«Назад»');
        Navigator.of(context).maybePop();
      },
    );
  }
}
