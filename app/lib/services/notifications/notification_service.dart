import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../common/logging/app_logger.dart';

/// Сервис локальных уведомлений: напоминание за 1 час до начала игры,
/// если пользователь поставил галку «уведомления» (модуль Д).
///
/// Ответственность (SRP): планирование и отмена локальных уведомлений.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;

  /// Часовой пояс устройства (для корректного планирования).
  tz.Location _localLocation = tz.UTC;

  /// Создаёт сервис (используйте [create] — он инициализирует окружение).
  ///
  /// [plugin] — инициализированный плагин.
  NotificationService._(this._plugin);

  /// Инициализирует плагин и часовой пояс устройства.
  ///
  /// Без параметров; возвращает готовый сервис.
  static Future<NotificationService> create() async {
    final service = NotificationService._(FlutterLocalNotificationsPlugin());
    try {
      tz_data.initializeTimeZones();
      final zoneName = await FlutterTimezone.getLocalTimezone();
      service._localLocation = tz.getLocation(zoneName);
      tz.setLocalLocation(service._localLocation);

      await service._plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          ),
        ),
      );

      // Разрешения на уведомления (Android 13+/iOS).
      await service._plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      AppLogger.info('NotificationService', 'Инициализация', 'Готово');
    } catch (error, stackTrace) {
      // Без разрешений приложение работает без напоминаний — не фатально.
      AppLogger.error(
        'NotificationService',
        'Инициализация — ошибка',
        error,
        stackTrace,
      );
    }
    return service;
  }

  /// Планирует напоминание за час до старта игры.
  ///
  /// [gameId] — идентификатор игры (используется как id уведомления);
  /// [title] — заголовок игры; [gameStart] — время начала.
  /// Если время уже прошло — напоминание не планируется.
  Future<void> scheduleGameReminder({
    required String gameId,
    required String title,
    required DateTime gameStart,
  }) async {
    final remindAt = gameStart.subtract(const Duration(hours: 1));
    if (remindAt.isBefore(DateTime.now())) {
      AppLogger.debug(
        'NotificationService',
        'Напоминание пропущено',
        'Время уже прошло: $remindAt',
      );
      return;
    }
    try {
      final id = gameId.hashCode & 0x7fffffff;
      await _plugin.zonedSchedule(
        id,
        'Игра скоро начнётся',
        '«$title» начинается через час',
        tz.TZDateTime.from(remindAt, _localLocation),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'game_reminders',
            'Напоминания об играх',
            channelDescription: 'Уведомления за час до начала игры',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      AppLogger.info(
        'NotificationService',
        'Напоминание запланировано',
        '«$title» на $remindAt',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'NotificationService',
        'Планирование — ошибка',
        error,
        stackTrace,
      );
    }
  }

  /// Отменяет напоминание игры [gameId].
  ///
  /// [gameId] — идентификатор игры.
  Future<void> cancelGameReminder(String gameId) async {
    try {
      await _plugin.cancel(gameId.hashCode & 0x7fffffff);
      AppLogger.debug('NotificationService', 'Напоминание отменено', gameId);
    } catch (error, stackTrace) {
      AppLogger.error(
        'NotificationService',
        'Отмена — ошибка',
        error,
        stackTrace,
      );
    }
  }

  /// Планирует уведомление повторно при перезапуске (восстановление).
  ///
  /// [gameId] — игра; [title] — название; [gameStart] — время старта.
  Future<void> restoreReminder({
    required String gameId,
    required String title,
    required DateTime gameStart,
  }) =>
      scheduleGameReminder(gameId: gameId, title: title, gameStart: gameStart);
}
