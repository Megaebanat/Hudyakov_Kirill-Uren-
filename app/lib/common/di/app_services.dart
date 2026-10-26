import '../../data/datasources/prefs_store.dart';
import '../../data/datasources/session_store.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/documents/document_service.dart';
import '../../services/notifications/notification_service.dart';
import '../config/app_config.dart';

/// Контейнер зависимостей приложения (composition root, собирается в bootstrap).
///
/// Единственное место, где связаны реализации репозиториев и сервисов.
/// Экраны получают контейнер через [AppScope] и зависят от абстракций (DIP):
/// замена mock/реального бэкенда не затрагивает presentation-слой.
///
/// Ответственность (SRP): хранение сконфигурированных сервисов.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppServices {
  /// Конфигурация сборки.
  final AppConfig config;

  /// Хранилище сессии (токен и профиль).
  final SessionStore sessionStore;

  /// Хранилище настроек и состояния последнего экрана.
  final PrefsStore prefsStore;

  /// Репозиторий аутентификации.
  final AuthRepository authRepository;

  /// Репозиторий профиля.
  final ProfileRepository profileRepository;

  /// Репозиторий игр.
  final GameRepository gameRepository;

  /// Репозиторий статистики.
  final StatisticsRepository statisticsRepository;

  /// Локальные уведомления (напоминание за час до игры).
  final NotificationService notifications;

  /// Аналитика (Яндекс Метрика через абстракцию).
  final AnalyticsService analytics;

  /// Генератор PDF-документов (политика, соглашение).
  final DocumentService documents;

  /// Создаёт контейнер зависимостей.
  ///
  /// Все параметры обязательны — неполная сборка невозможна.
  AppServices({
    required this.config,
    required this.sessionStore,
    required this.prefsStore,
    required this.authRepository,
    required this.profileRepository,
    required this.gameRepository,
    required this.statisticsRepository,
    required this.notifications,
    required this.analytics,
    required this.documents,
  });
}
