import 'package:flutter/widgets.dart';
import 'package:network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';
import 'app_services.dart';
import '../../data/datasources/prefs_store.dart';
import '../../data/datasources/remote_api_data_source.dart';
import '../../data/datasources/session_store.dart';
import '../../data/logging/logging_http_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/game_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/documents/document_service.dart';
import '../../services/notifications/notification_service.dart';

/// Сборка (bootstrap) приложения: единая точка создания зависимостей.
///
/// Порядок: конфигурация → хранилища → HTTP-клиент (mock или REST,
/// в декораторах логирования и аутентификации) → библиотека сети →
/// репозитории → сервисы. Связывание объектов находится только здесь,
/// что упрощает подмену реализаций (тесты, реальный бэкенд).
///
/// Ответственность (SRP): только composition root приложения.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppBootstrap {
  /// Приватный конструктор: только статический метод [create].
  AppBootstrap._();

  /// Создаёт полностью сконфигурированный контейнер [AppServices].
  ///
  /// Без параметров; асинхронно инициализирует SharedPreferences и сервисы.
  static Future<AppServices> create() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppLogger.info('Bootstrap', 'Инициализация приложения', 'Начало');

    final config = AppConfig.current();
    final prefs = await SharedPreferences.getInstance();
    final sessionStore = SessionStore(prefs);
    final prefsStore = PrefsStore(prefs);

    // Транспортный HTTP-клиент: mock (демо-режим) или реальный REST API.
    final HttpClient base = config.useMock
        ? MockHttpClient()
        : DartHttpClient(
            transport: IoHttpTransport(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
            ),
            baseUrl: config.baseUrl,
            defaultHeaders: const {'Content-Type': 'application/json'},
          );

    // Декораторы: логирование запросов (INFO/DEBUG/ERROR) поверх
    // аутентификации (Bearer-токен из локальной сессии).
    final HttpClient client = LoggingHttpClient(
      AuthenticatedHttpClient(
        inner: base,
        tokenProvider: () => sessionStore.token,
      ),
    );

    final network = NetworkFactory.create(
      config: ApiConfig(baseUrl: config.baseUrl),
      client: client,
    );
    final api = RemoteApiDataSource(network);

    final authRepository = AuthRepositoryImpl(
      api: api,
      sessionStore: sessionStore,
    );
    final profileRepository = ProfileRepositoryImpl(
      api: api,
      sessionStore: sessionStore,
    );
    final gameRepository = GameRepositoryImpl(api: api, prefs: prefsStore);
    final statisticsRepository = StatisticsRepositoryImpl(api: api);

    final notifications = await NotificationService.create();
    final analytics = YandexMetricaAnalyticsService();
    await analytics.init();

    AppLogger.info(
      'Bootstrap',
      'Инициализация приложения',
      'Готово '
          '(mock: ${config.useMock})',
    );

    return AppServices(
      config: config,
      sessionStore: sessionStore,
      prefsStore: prefsStore,
      authRepository: authRepository,
      profileRepository: profileRepository,
      gameRepository: gameRepository,
      statisticsRepository: statisticsRepository,
      notifications: notifications,
      analytics: analytics,
      documents: DocumentService(),
    );
  }
}
