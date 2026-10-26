import 'package:flutter/widgets.dart';

import 'app_services.dart';

/// Лёгкий service locator на основе InheritedWidget (без сторонних DI-пакетов).
///\n/// Ответственность (SRP): распространение [AppServices] по дереву виджетов.
///\n/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppScope extends InheritedWidget {
  /// Сконфигурированный контейнер зависимостей.
  final AppServices services;

  /// Создаёт scope с дочерним деревом [child].
  const AppScope({super.key, required this.services, required super.child});

  /// Возвращает контейнер сервисов из контекста.
  ///\n/// [context] — контекст виджета под [AppScope]; кидает ошибку, если scope
  /// выше не найден (программная ошибка сборки дерева).
  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope не найден выше по дереву виджетов');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
