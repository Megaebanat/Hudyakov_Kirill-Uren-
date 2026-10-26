import 'package:flutter/material.dart';

import '../../../common/logging/app_logger.dart';

/// Миксин ведения лога жизненного цикла экрана (INFO при открытии/закрытии).
///
/// Требование ТЗ: «Логирование жизненного цикла экранов» — каждая реализация
/// State обязана объявить [screenName].
///
/// Ответственность (SRP): только запись жизненного цикла.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
mixin ScreenLifecycle<T extends StatefulWidget> on State<T> {
  /// Имя экрана для лога (например, «Login»).
  String get screenName;

  @override
  void initState() {
    super.initState();
    AppLogger.info('Screen/$screenName', 'Жизненный цикл', 'экран открыт');
  }

  @override
  void dispose() {
    AppLogger.info('Screen/$screenName', 'Жизненный цикл', 'экран закрыт');
    super.dispose();
  }
}
