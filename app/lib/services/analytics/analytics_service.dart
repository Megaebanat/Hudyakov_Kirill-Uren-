import '../../common/logging/app_logger.dart';

/// Абстракция аналитики (зависимость presentation от абстракции — DIP).
///
/// Позволяет подменить реализацию (Яндекс Метрика, тестовый recorder)
/// без изменения кода экранов.
///
/// Ответственность (SRP): только отправка событий аналитики.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract interface class AnalyticsService {
  /// Инициализирует SDK аналитики (до runApp).
  Future<void> init();

  /// Отправляет событие [name] с параметрами [parameters].
  ///
  /// [name] — имя события; [parameters] — параметры события.
  Future<void> logEvent(String name, {Map<String, Object?> parameters});
}

/// Реализация для Яндекс Метрики.
///
/// TODO(Модуль Ж): при публикации подключить SDK Яндекс Метрики
/// (пакет `yandex_metrica_plugin`), вызвать `YandexMetrica.activate`
/// с API-ключом и `YandexMetrica.enableActivityAutoTracking`.
/// Сейчас события фиксируются в логах — контракт уже соблюдён,
/// замена реализации не требует изменения вызывающего кода (OCP).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class YandexMetricaAnalyticsService implements AnalyticsService {
  @override
  Future<void> init() async {
    // TODO(Модуль Ж): YandexMetrica.activate(ApiKeyConfig.YANDEX_METRIKA_API_KEY).
    AppLogger.info(
      'MetricaService',
      'Инициализация Метрики',
      'SDK не подключён (TODO)',
    );
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    // TODO(Модуль Ж): YandexMetrica.reportEvent(name, parameters: parameters).
    final details = parameters.entries
        .map((e) => '${e.key}=${e.value}')
        .join(', ');
    AppLogger.info('MetricaService', 'Событие: $name', details);
  }
}

/// Тестовый recorder: собирает события в памяти для автотестов.
///
/// Ответственность (SRP): только запись событий в список.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class RecordingAnalyticsService implements AnalyticsService {
  /// Записанные события «имя → параметры».
  final List<({String name, Map<String, Object?> parameters})> events = [];

  @override
  Future<void> init() async {}

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    events.add((name: name, parameters: parameters));
  }
}
