# Архитектура приложения

Приложение разделено на три слоя с направлением зависимостей **строго внутрь**:
`PRESENTATION → DOMAIN ← DATA`. Домен не знает ни о Flutter, ни о сети.

```
app/lib/
├── common/            # сквозные утилиты (без бизнес-логики)
│   ├── config/        # AppConfig: baseUrl, флаг mock-режима
│   ├── di/            # AppBootstrap, AppServices, AppScope
│   ├── errors/        # AppErrorHandler (глобальные уведомления)
│   ├── logging/       # AppLogger (DEBUG/INFO/ERROR, единый формат)
│   └── utils/         # EmailValidator, Formatters
├── domain/            # ЯДРО: не зависит ни от чего, кроме Dart
│   ├── entities/      # AppUser, Session, Game, GameResult, PlayerStatistics
│   ├── errors/        # DomainException, ValidationException
│   ├── repositories/  # абстракции репозиториев (интерфейсы)
│   └── usecases/      # 11 сценариев (по одному классу на действие)
├── data/              # реализация контрактов домена
│   ├── datasources/   # RemoteApiDataSource, SessionStore, PrefsStore
│   ├── logging/       # LoggingHttpClient (декоратор логирования)
│   ├── mappers/       # DTO ↔ сущности, ErrorMapper
│   └── repositories/  # *RepositoryImpl
├── services/          # платформенные сервисы (уведомления, PDF, аналитика)
└── presentation/      # UI: экраны, ViewModel, виджеты, мапперы, навигация
    ├── mappers/       # GameCardMapper (Game → GameCardData)
    ├── navigation/    # имена маршрутов, аргументы, роутер
    ├── screens/       # 15 экранов + переиспользуемые виджеты
    └── viewmodels/    # ChangeNotifier-модели экранов
```

## Ключевые решения

### 1. Независимые библиотеки

- `packages/uikit` — цвета, типографика, тема и 9 компонентов
  (`AppButton`, `AppTextField`, `AppSelect` + BottomSheet, `AppPagination`,
  `AppCard`, `AppBottomBar`, `AppTimer`, `AppCheckbox`, `AppErrorBanner`).
- `packages/network` — чистый Dart: транспорт (`HttpTransport`),
  клиент (`HttpClient`), декоратор аутентификации (`AuthenticatedHttpClient`),
  централизованный разбор ответов (`ResponseParser`), DTO, запросы API-групп
  (`AuthApi`, `ProfileApi`, `GamesApi`, `StatisticsApi`) и единая обработка
  ошибок (`NetworkException`). Демо/тесты — `MockHttpClient`.

Приложение зависит **только от абстракций** библиотеки сети, поэтому
реализацию можно заменить (Dio/Fetch) без изменения `app/` (OCP, DIP).

### 2. Управление состоянием

- `ViewModel extends ChangeNotifier` — базовый класс с методом-шаблоном
  `guard<T>()`: фиксирует ERROR в логе, показывает пользователю уведомление
  через `AppErrorHandler`, возвращает `null` при сбое.
- Экраны подписываются на ViewModel и вызывают `setState` через слушателя.
- Виртуальные машины создаются в `didChangeDependencies` из `AppScope`.

### 3. Внедрение зависимостей

`AppBootstrap.create()` — единственный composition root. Порядок сборки:
конфигурация → хранилища → HTTP-клиент (декораторы логирования и
аутентификации) → `NetworkFactory` → репозитории → сервисы.
Экземпляры передаются вниз по дереву через `AppScope` (InheritedWidget).

### 4. Навигация

Navigator 1.0 с именованными маршрутами (`RouteNames`) и типизированными
аргументами (`GameRouteArgs`, `PlayerRouteArgs`, `SuccessRouteArgs`).
`RoutePersistenceObserver` сохраняет последний маршрут — после перезапуска
приложение восстанавливает экран (`PrefsStore.lastRoute`).

### 5. Поток ошибки

```
репозиторий (catch) → AppLogger.error → ErrorMapper.map
        → ViewModel.guard → AppErrorHandler.report
        → корневой слушатель → AppErrorBanner.show (5 c + ✕)
```

Пользователь всегда видит понятное сообщение; технические детали остаются
в логах.

### 6. Логирование

Единый формат `[Тег]: Событие — Детали` (`AppLogger.format`).
DEBUG — данные и результаты, INFO — жизненный цикл и действия пользователя,
ERROR — исключения. Сетевые операции логируются декоратором
`LoggingHttpClient` (старт — INFO, успех — DEBUG, ошибка — ERROR).

## Тесты

| Проект | Что покрыто | Команда |
| --- | --- | --- |
| `packages/network` | все 11 эндпоинтов, offline, 5xx, 401 | `dart test` |
| `app` | репозитории (11 запросов поверх mock), хранилища, ViewModel-игр, валидатор email, форматтеры, маппер карточек | `flutter test` |
| `storybook` | smoke-тест витрины | `flutter test` |

> Дата создания: 19-10-2026
> Автор: Участник №00
