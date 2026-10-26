import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import 'demos.dart';

/// Раздел витрины: название и страница с демо.
///
/// Ответственность (SRP): запись каталога разделов.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GalleryEntry {
  /// Название раздела в каталоге.
  final String title;

  /// Краткое описание того, что демонстрируется.
  final String subtitle;

  /// Иконка раздела.
  final IconData icon;

  /// Страница с демо-состояниями.
  final Widget page;

  /// Создаёт запись каталога.
  ///
  /// [title] — название; [subtitle] — описание; [icon] — иконка;
  /// [page] — страница демо.
  const GalleryEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });
}

/// Главная страница StoryBook — каталог разделов библиотеки UIKit.
///
/// Ответственность (SRP): навигация по разделам витрины.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GalleryPage extends StatelessWidget {
  /// Создаёт страницу каталога.
  const GalleryPage({super.key});

  /// Каталог разделов витрины.
  static final List<GalleryEntry> entries = [
    GalleryEntry(
      title: 'Цвета',
      subtitle: 'Палитра дизайн-системы',
      icon: Icons.palette_outlined,
      page: const ColorsDemoPage(),
    ),
    GalleryEntry(
      title: 'Типографика',
      subtitle: 'Шрифт Inter и размеры',
      icon: Icons.text_fields_outlined,
      page: const TypographyDemoPage(),
    ),
    GalleryEntry(
      title: 'Поле ввода',
      subtitle: 'Все состояния',
      icon: Icons.edit_outlined,
      page: const TextFieldDemoPage(),
    ),
    GalleryEntry(
      title: 'Кнопка',
      subtitle: 'Primary / Secondary / Ghost, disabled, loading',
      icon: Icons.smart_button_outlined,
      page: const ButtonDemoPage(),
    ),
    GalleryEntry(
      title: 'Селект + BottomSheet',
      subtitle: 'Выбор значения нижним листом',
      icon: Icons.arrow_drop_down_circle_outlined,
      page: const SelectDemoPage(),
    ),
    GalleryEntry(
      title: 'Пагинация',
      subtitle: 'Индикаторы страниц',
      icon: Icons.more_horiz_rounded,
      page: const PaginationDemoPage(),
    ),
    GalleryEntry(
      title: 'Карточка',
      subtitle: 'Варианты карточек',
      icon: Icons.crop_square,
      page: const CardDemoPage(),
    ),
    GalleryEntry(
      title: 'Нижнее меню',
      subtitle: 'Bottom Bar с центральной кнопкой',
      icon: Icons.menu_rounded,
      page: const BottomBarDemoPage(),
    ),
    GalleryEntry(
      title: 'Таймер',
      subtitle: 'Обратный отсчёт',
      icon: Icons.timer_outlined,
      page: const TimerDemoPage(),
    ),
    GalleryEntry(
      title: 'Чекбокс',
      subtitle: 'Все состояния',
      icon: Icons.check_box_outlined,
      page: const CheckboxDemoPage(),
    ),
    GalleryEntry(
      title: 'Уведомление об ошибке',
      subtitle: '5 секунд + закрытие кнопкой',
      icon: Icons.error_outline,
      page: const ErrorBannerDemoPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UIKit StoryBook'),
        centerTitle: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return AppCard(
            title: entry.title,
            subtitle: entry.subtitle,
            leadingIcon: entry.icon,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => entry.page),
            ),
          );
        },
      ),
    );
  }
}
