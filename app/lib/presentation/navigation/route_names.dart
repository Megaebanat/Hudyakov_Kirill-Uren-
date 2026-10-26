import 'package:flutter/widgets.dart';

import '../../common/logging/app_logger.dart';
import '../../common/di/app_services.dart';

/// Именованные маршруты приложения.
///\n/// Имена используются и для навигации, и для сохранения последнего экрана
/// (восстановление состояния после перезапуска — модуль Г).
///\n/// Ответственность (SRP): реестр маршрутов.
///\n/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract final class RouteNames {
  /// Экран запуска (Splash).
  static const String splash = '/splash';

  /// Приветствие (3 экрана, только первый запуск).
  static const String onboarding = '/onboarding';

  /// Регистрация.
  static const String register = '/register';

  /// Вход.
  static const String login = '/login';

  /// Основной экран (Landing) с боковым меню.
  static const String landing = '/landing';

  /// Планирование игры (Schedule Game).
  static const String scheduleGame = '/schedule-game';

  /// Успех публикации (Success).
  static const String success = '/success';

  /// Список игр (Discover Combats).
  static const String combats = '/combats';

  /// Информация об игре (Combat Information).
  static const String combatInfo = '/combat-info';

  /// Информация об игроке (Player Information).
  static const String playerInfo = '/player-info';

  /// Статистика (Statistics).
  static const String statistics = '/statistics';

  /// Игра «Картинка».
  static const String gameImage = '/game-image';

  /// Игра «Круг».
  static const String gameCircle = '/game-circle';

  /// Политика конфиденциальности (PDF).
  static const String privacyPolicy = '/privacy-policy';

  /// Пользовательское соглашение.
  static const String userAgreement = '/user-agreement';

  /// Маршруты, допустимые для восстановления после перезапуска (без аргументов).
  static const Set<String> restorable = {
    landing,
    combats,
    statistics,
    scheduleGame,
    privacyPolicy,
    userAgreement,
  };
}

/// Наблюдатель навигации: сохраняет последний открытый экран.
///\n/// Благодаря этому после перезапуска приложение возвращается на тот же
/// экран (состояние последнего экрана сохраняется — требование модуля Г).
///\n/// Ответственность (SRP): персистентность маршрута навигации.
///\n/// Дата создания: 19-10-2026
/// Автор: Участник №00
class RoutePersistenceObserver extends NavigatorObserver {
  /// Хранилище настроек (запись последнего маршрута).
  final AppServices services;

  /// Создаёт наблюдатель навигации.
  ///\n/// [services] — контейнер сервисов (нужен [PrefsStore]).
  RoutePersistenceObserver(this.services);

  /// Сохраняет маршрут [name], если он входит в белый список восстановления.
  ///\n/// [name] — имя маршрута; без возвращаемого значения.
  void _save(String? name) {
    if (name == null || !RouteNames.restorable.contains(name)) return;
    services.prefsStore.saveLastRoute(name);
    AppLogger.debug('RouteObserver', 'Экран сохранён', name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _save(route.settings.name);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _save(newRoute?.settings.name);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _save(previousRoute?.settings.name);
}
