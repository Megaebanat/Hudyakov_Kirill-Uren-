import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../common/di/app_scope.dart';
import '../common/di/app_services.dart';
import '../common/errors/app_error_handler.dart';
import 'navigation/app_router.dart';
import 'navigation/route_names.dart';

/// Корневой виджет приложения: тема, маршрутизация, глобальные уведомления.
///
/// Ответственность (SRP): настройка MaterialApp и глобальных слушателей
/// (ошибки через [AppErrorHandler], восстановление последнего экрана через
/// [RoutePersistenceObserver]).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class App extends StatefulWidget {
  /// Сконфигурированный контейнер зависимостей (см. [AppBootstrap]).
  final AppServices services;

  /// Создаёт корневой виджет.
  ///
  /// [services] — контейнер сервисов приложения.
  const App({super.key, required this.services});

  @override
  State<App> createState() => _AppState();
}

/// Состояние корневого виджета: ключи навигации и подписка на ошибки.
class _AppState extends State<App> {
  /// Ключ навигатора (доступ к контексту для показа ошибок).
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// Ключ корневого ScaffoldMessenger (показ уведомлений об ошибках).
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    AppErrorHandler.message.addListener(_showPendingError);
  }

  @override
  void dispose() {
    AppErrorHandler.message.removeListener(_showPendingError);
    super.dispose();
  }

  /// Показывает ожидающую ошибку через [AppErrorBanner] (5 секунд + ✕).
  ///
  /// Без параметров и возвращаемого значения.
  void _showPendingError() {
    final message = AppErrorHandler.message.value;
    if (message == null) return;
    final context = _navigatorKey.currentContext;
    if (context != null) {
      AppErrorBanner.show(context, message);
    }
    AppErrorHandler.consume();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: widget.services,
      child: MaterialApp(
        title: 'Профессионалы',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        navigatorKey: _navigatorKey,
        scaffoldMessengerKey: _messengerKey,
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        navigatorObservers: [RoutePersistenceObserver(widget.services)],
      ),
    );
  }
}
