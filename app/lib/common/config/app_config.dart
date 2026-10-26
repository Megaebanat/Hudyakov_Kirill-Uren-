/// Конфигурация приложения.
///
/// Единственное место хранения параметров сборки: режим демо-данных (mock),
/// базовый URL REST API, номер участника для комментариев, ссылка на макет.
/// Изменение настроек выполняется только здесь (единый источник истины).
///
/// Ответственность (SRP): хранение конфигурационных параметров приложения.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppConfig {
  /// Режим демо-данных: true — запросы идут в [MockHttpClient] библиотеки,
  /// false — на реальный REST API (базовый URL берётся из [baseUrl]).
  final bool useMock;

  /// Базовый URL реального REST API (SaaS-бэкенда организаторов).
  final String baseUrl;

  /// Номер участника чемпионата (подставляется перед сдачей).
  final String participantNumber;

  /// Версия приложения (для отображения и публикации в ruStore).
  final String appVersion;

  /// Ссылка на макет Figma (эталон вёрстки).
  final String figmaUrl;

  /// Создаёт конфигурацию.
  ///
  /// [useMock] — демо-режим; [baseUrl] — URL API; [participantNumber] —
  /// номер участника; [appVersion] — версия; [figmaUrl] — ссылка на макет.
  const AppConfig({
    required this.useMock,
    required this.baseUrl,
    required this.participantNumber,
    required this.appVersion,
    required this.figmaUrl,
  });

  /// Текущая конфигурация сборки (демо-режим включён до выдачи URL API).
  factory AppConfig.current() => const AppConfig(
    useMock: true,
    baseUrl: 'https://api.example.ru',
    participantNumber: '00',
    appVersion: '1.0.0',
    figmaUrl: 'https://www.figma.com/design/TJ8zZ5ETY68fPatL075IWU/',
  );
}
