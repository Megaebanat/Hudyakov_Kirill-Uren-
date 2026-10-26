import 'package:flutter/material.dart';

import '../../common/logging/app_logger.dart';
import '../../domain/entities/game.dart';
import '../../domain/usecases/create_game_use_case.dart';
import '../../services/notifications/notification_service.dart';
import 'view_model.dart';

/// ViewModel экрана планирования игры (Schedule Game).
///
/// Форма: название, категория (селект), дата и время (нативные диалоги
/// вызываются экраном), галка уведомлений. Отправка: создание игры на
/// сервере → запланирование локального уведомления за 1 час (если галка) →
/// переход на экран Success.
///
/// Ответственность (SRP): состояние формы и сценарий публикации игры.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class ScheduleGameViewModel extends ViewModel {
  final CreateGameUseCase _createGame;
  final NotificationService _notifications;

  /// Контроллер названия игры.
  final TextEditingController titleController = TextEditingController();

  /// Выбранная категория (null — не выбрана).
  GameCategory? category;

  /// Выбранная дата начала (null — не выбрана).
  DateTime? date;

  /// Выбранное время начала (null — не выбрано).
  TimeOfDay? time;

  /// Отправлять ли локальное уведомление за час до игры.
  bool notifyBeforeGame = true;

  /// Ошибка поля «название».
  String? titleError;

  /// Ошибка поля «категория/дата/время».
  String? formError;

  /// Создаёт ViewModel.
  ///
  /// [createGame] — use case создания игры; [notifications] — сервис
  /// локальных уведомлений.
  ScheduleGameViewModel({
    required this._createGame,
    required this._notifications,
  });

  @override
  void dispose() {
    AppLogger.info('ScheduleGameViewModel', 'Жизненный цикл', 'Уничтожен');
    titleController.dispose();
    super.dispose();
  }

  /// Выбрана ли форма полностью (доступна кнопка Publish).
  bool get canSubmit =>
      titleController.text.trim().isNotEmpty &&
      category != null &&
      date != null &&
      time != null;

  /// Полная дата+время старта либо null.
  DateTime? get scheduledAt {
    final d = date;
    final t = time;
    if (d == null || t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  /// Обновляет название (после ввода в поле).
  void setTitle(String value) {
    titleError = null;
    notifyListeners();
  }

  /// Устанавливает категорию [value] из селекта.
  void setCategory(GameCategory value) {
    category = value;
    formError = null;
    notifyListeners();
  }

  /// Устанавливает дату [value] из нативного диалога.
  void setDate(DateTime value) {
    date = value;
    formError = null;
    notifyListeners();
  }

  /// Устанавливает время [value] из нативного диалога.
  void setTime(TimeOfDay value) {
    time = value;
    formError = null;
    notifyListeners();
  }

  /// Переключает галку уведомлений [value].
  void setNotify(bool value) {
    notifyBeforeGame = value;
    notifyListeners();
  }

  /// Публикует игру: валидация → создание на сервере → уведомление →
  /// [onSuccess] с созданной игрой.
  ///
  /// [onSuccess] — колбэк после успешной публикации.
  Future<void> publish({required void Function(Game game) onSuccess}) async {
    titleError = null;
    formError = null;
    final title = titleController.text.trim();

    if (title.isEmpty) {
      titleError = 'Введите название игры';
      notifyListeners();
      return;
    }
    if (category == null || scheduledAt == null) {
      formError = 'Выберите категорию, дату и время';
      notifyListeners();
      return;
    }

    AppLogger.info(
      'ScheduleGameViewModel',
      'Нажатие кнопки',
      '«Publish» — $title (${category!.name})',
    );

    final game = await guard<Game>(
      tag: 'ScheduleGameViewModel',
      event: 'Публикация игры',
      action: () => _createGame(
        title: title,
        category: category!,
        scheduledAt: scheduledAt!,
      ),
    );
    if (game == null) return;

    if (notifyBeforeGame) {
      await _notifications.scheduleGameReminder(
        gameId: game.id,
        title: game.title,
        gameStart: game.scheduledAt,
      );
    }
    AppLogger.info(
      'ScheduleGameViewModel',
      'Публикация игры',
      'Успех: ${game.title}',
    );
    onSuccess(game);
  }
}
