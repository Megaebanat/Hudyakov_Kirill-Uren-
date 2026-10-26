# storybook — витрина UIKit

Отдельное Flutter-приложение, в котором визуально представлены **все
состояния всех компонентов** библиотеки [`uikit`](../packages/uikit/README.md)
(требование модуля Б, спринт-1).

## Запуск

```powershell
flutter pub get
flutter run
```

## Что показано

`lib/gallery/demos.dart` — страницы-демонстрации 11 разделов: цвета,
типографика, поле ввода (все состояния), Select + BottomSheet, кнопка (все
состояния), Pagination, карточка, Bottom Bar, Timer, Checkbox, уведомление об
ошибке.

## Проверка

```powershell
flutter analyze
flutter test
```

> Дата создания: 19-10-2026
> Автор: Участник №00
