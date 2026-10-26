# app — мобильное приложение «ИМЭЧ»

Основное приложение чемпионата «Профессионалы» (Flutter, Android 14+ /
iOS 18+). Архитектура — **DOMAIN / PRESENTATION / DATA**.

## Запуск

```powershell
flutter pub get
flutter run            # демо-режим (встроенный mock-бэкенд)
flutter test           # тесты
flutter analyze        # статический анализ
```

Демо-доступ: `demo@mail.ru` / `123456`.

## Требования к Android SDK

- `minSdk = 34` (Android 14+), `compileSdk`/`targetSdk` — из Flutter.
- Core library desugaring включён (нужно для `flutter_local_notifications`).
- NDK версии Flutter (`28.2.13676358`) — устанавливается автоматически при
  первой сборке (`sdkmanager --install "ndk;28.2.13676358"`).
- Разрешения манифеста: интернет, уведомления, камера, чтение изображений.

## Конфигурация

`lib/common/config/app_config.dart`:

```dart
static const bool useMock = true;                    // false → реальный REST API
static const String baseUrl = 'https://api.example.ru';
```

## Структура `lib/`

| Папка | Содержимое |
| --- | --- |
| `common/` | конфигурация, DI (`AppBootstrap`, `AppScope`), логгер, обработчик ошибок, утилиты |
| `domain/` | сущности, доменные ошибки, интерфейсы репозиториев, 11 use case |
| `data/` | источники данных, хранилища, мапперы, реализации репозиториев |
| `services/` | уведомления, PDF-документы, аналитика |
| `presentation/` | экраны, ViewModel, виджеты, мапперы, навигация |

Подробности — в [../docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md).

## Экраны

Splash · Онбординг (3) · Регистрация · Вход · Landing · Schedule Game ·
Success · Discover Combats · Combat Information · Player Information ·
Statistics · Privacy Policy · User Agreement · Game Image · Game Circle.

## Зависимости

`uikit`, `network` (локальные библиотеки), `shared_preferences`,
`cached_network_image`, `image_picker`, `flutter_local_notifications`,
`timezone`, `flutter_timezone`, `pdf`, `printing`.

> Дата создания: 19-10-2026
> Автор: Участник №00
