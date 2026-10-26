import 'package:flutter/material.dart';

import 'common/di/app_bootstrap.dart';
import 'presentation/app.dart';

/// Точка входа приложения чемпионата «Профессионалы».
///
/// Порядок: инициализация зависимостей (bootstrap) → запуск виджета [App].
/// До runApp выполняются только асинхронные инициализации, требующие
/// платформенных биндингов (SharedPreferences, локальные уведомления).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
Future<void> main() async {
  final services = await AppBootstrap.create();
  runApp(App(services: services));
}
