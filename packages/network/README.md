# network — независимая библиотека сетевого слоя

Самостоятельный Dart-пакет (без зависимости от Flutter) с собственным
жизненным циклом и версией (`1.0.0`): модели сервера, HTTP-клиент, запросы и
централизованная обработка ошибок. Приложение работает **только через
абстракции** этой библиотеки, поэтому реализацию можно заменить без правок в
`app/`.

## Характеристики независимого модуля

| Характеристика | Реализация |
| --- | --- |
| Изолированность | отдельный проект `packages/network`, чистый Dart |
| Абстрагированность | приложение зависит от `HttpClient`, `AuthApi`, `ProfileApi`, `GamesApi`, `StatisticsApi` |
| Заменяемость | `HttpClient` — интерфейс: `DartHttpClient`, `MockHttpClient`, любая другая реализация |
| Независимое версионирование | `version: 1.0.0` (semver) |

## Состав

```
lib/src/
├── api/          # AuthApi, ProfileApi, GamesApi, StatisticsApi (11 запросов)
├── config/       # ApiConfig — baseUrl, таймауты, заголовки (единая точка)
├── dto/          # модели сервера (auth, profile, game, statistics, error)
├── errors/       # NetworkException и наследники (offline, 5xx, 401, ...)
├── factory/      # NetworkFactory + NetworkClient — фасад/composition root
├── http/         # HttpClient (абстракция), DartHttpClient,
│                 # AuthenticatedHttpClient, ResponseParser
├── mock/         # MockHttpClient — детерминированный сервер в памяти
└── transport/    # HttpTransport (абстракция), IoHttpTransport, HttpRequest
```

## Принципы

- **SRP:** `HttpClient` — только запросы; `ResponseParser` — разбор ответов;
  `NetworkException` — ошибки; `ApiConfig` — конфигурация.
- **OCP/DIP:** приложение зависит от интерфейсов; новые типы запросов
  добавляются без изменения существующего кода.
- **LSP:** `MockHttpClient`, `DartHttpClient` и декораторы
  (`AuthenticatedHttpClient`, `LoggingHttpClient`) взаимозаменяемы.
- **DRY:** базовый URL, таймауты и заголовки — в `ApiConfig`; ошибки — через
  центральный парсер/исключения; методы GET/POST/PUT/DELETE — в одном месте.

## Запросы (11)

1. Авторизация · 2. Регистрация · 3. Изменение профиля ·
4. Получение профиля · 5. Выход · 6. Создание игры · 7. Список игр ·
8. Информация об игре · 9. Подключение к игре · 10. Статистика игрока ·
11. Сохранение результата игры.

## Тесты

Каждый из 11 запросов покрыт тестом, плюс сценарии отсутствия сети, ошибки
сервера (5xx) и неавторизованного доступа (401):

```powershell
dart test
```

> Дата создания: 19-10-2026
> Автор: Участник №00
