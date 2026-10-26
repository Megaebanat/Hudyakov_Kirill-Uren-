# Модуль Ж — Подготовка продукта (Спринт-6)

Итоговый спринт: презентация для разработчиков, подключение Яндекс Метрики
и подготовка приложения к публикации в RuStore.

## 1. Презентация для разработчиков

Цель — рассказать о **реализации**, а не продавать продукт. Структура:

1. **Обзор решения** — монорепозиторий: `app` + независимые
   `packages/uikit`, `packages/network` + `storybook`.
2. **Схема классов** (диаграмма):
   - слой `domain`: `AppUser`, `Game`, `GameResult`, `PlayerStatistics`,
     интерфейсы репозиториев, 11 use case;
   - слой `data`: `*RepositoryImpl`, `RemoteApiDataSource`, `SessionStore`,
     `PrefsStore`, `ErrorMapper`, `LoggingHttpClient`;
   - слой `presentation`: экраны, `ViewModel`, `AppScope`, роутер;
   - библиотеки: `NetworkClient`, `HttpClient`, `AuthenticatedHttpClient`,
     `ResponseParser`, `MockHttpClient`, `NetworkFactory`.
3. **Архитектурные решения** — DOMAIN/PRESENTATION/DATA, направление
   зависимостей внутрь, паттерны: Декоратор (логирование, аутентификация),
   Фабрика (`NetworkFactory`), Шаблонный метод (`ViewModel.guard`),
   Mapper, DIP/OCP/SRP/DRY.
4. **Производительность** — сценарий «Игра Image»: профилирование
   (DevTools Performance / CPU), количество ребилдов на ход, оптимизации
   (детерминированная раскладка, точечные `notifyListeners`, `OverflowBox`
   вместо перестроения дерева при перетаскивании фрагмента).
5. **Используемые библиотеки** — `shared_preferences` (сессия/настройки),
   `cached_network_image` (кэш медиа), `image_picker` (фото),
   `flutter_local_notifications` + `timezone` + `flutter_timezone`
   (напоминания), `pdf` + `printing` (документы). Обосновать отказ от
   сторонних state-management/DI-фреймворков: стандартные `ChangeNotifier` и
   `InheritedWidget` закрывают задачу без лишних зависимостей.
6. **Метрики качества** — `flutter analyze` без замечаний, 100 % запросов
   покрыты тестами, единый формат логов.

Артефакты: PDF/PPTX презентации, скриншоты диаграммы классов и профилировщика.

## 2. Яндекс Метрика

Точка входа уже подготовлена: `AppServices.analytics`
(`YandexMetricaAnalyticsService`, `services/analytics/analytics_service.dart`).
Экраны зависят от абстракции `AnalyticsService`, поэтому подключение SDK не
меняет код экранов (OCP).

Шаги подключения:

1. Добавить пакет Яндекс Метрики для Flutter в `app/pubspec.yaml`.
2. В `YandexMetricaAnalyticsService.init()` вызвать активацию SDK с API-ключом
   (`ApiKeyConfig`) и включить авто-отслеживание активности.
3. В `logEvent()` вызвать `reportEvent(name, parameters)`.

События игры **Image** (уже отправляются):

| Событие | Когда | Параметры |
| --- | --- | --- |
| `game_started` | старт сессии | `game_id`, `category` |
| `puzzle_tile_selected` | выбор фрагмента | `tile` |
| `puzzle_tile_placed` | установка фрагмента (каждое движение) | `cell`, `correct`, `moves` |
| `game_completed` | пазл собран (отправка результата) | `game_id`, `moves` |
| `game_abandoned` | закрытие игры (поражение) | `game_id` |

По этим событиям в консоли Метрики строится диаграмма активности
пользователя — её скриншот добавляется в презентацию.

## 3. Подготовка к публикации в RuStore

- [ ] Уникальный `applicationId` (например, `ru.imech.app`) в
      `android/app/build.gradle.kts` вместо `com.example.app`.
- [ ] Release-подпись: создать keystore, добавить `signingConfigs` и
      `key.properties` (не коммитить секреты).
- [ ] Иконка приложения и splash-экран по макету.
- [ ] `version` и `versionCode` в `pubspec.yaml` (сейчас `1.0.0+1`).
- [ ] Сборка: `flutter build appbundle --release` (AAB для RuStore).
- [ ] Проверить разрешения манифеста (интернет, уведомления, камера, галерея)
      — уже добавлены в `android/app/src/main/AndroidManifest.xml`.
- [ ] Политика конфиденциальности: PDF в приложении и публичная ссылка для
      карточки RuStore.
- [ ] Возрастной рейтинг, категория, описание, скриншоты экранов.
- [ ] Проверить работу на устройстве Android 14+ и iPhone (iOS 18+).

> Дата создания: 19-10-2026
> Автор: Участник №00
