import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import 'gallery/gallery_page.dart';

/// Точка входа StoryBook-витрины библиотеки UIKit.
///
/// Назначение: демонстрация всех компонентов и их состояний, включая
/// цвета, типографику и состояния из макета. Не содержит бизнес-логики.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
void main() => runApp(const StoryBookApp());

/// Корневой виджет StoryBook: тёмная тема из библиотеки UIKit.
///
/// Ответственность (SRP): настройка приложения-витрины.
class StoryBookApp extends StatelessWidget {
  /// Создаёт корневой виджет.
  const StoryBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UIKit StoryBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const GalleryPage(),
    );
  }
}
