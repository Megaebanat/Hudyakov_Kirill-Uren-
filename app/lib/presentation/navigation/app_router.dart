import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/combats/combat_information_screen.dart';
import '../screens/combats/discover_combats_screen.dart';
import '../screens/docs/privacy_policy_screen.dart';
import '../screens/docs/user_agreement_screen.dart';
import '../screens/games/game_circle_screen.dart';
import '../screens/games/game_image_screen.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/player/player_information_screen.dart';
import '../screens/schedule/schedule_game_screen.dart';
import '../screens/schedule/success_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import 'route_args.dart';
import 'route_names.dart';

/// Маршрутизатор приложения (именованные маршруты, Navigator 1.0).
///
/// Именованная навигация выбрана осознанно: имена маршрутов сохраняются
/// и восстанавливаются после перезапуска (состояние последнего экрана).
///
/// Ответственность (SRP): сопоставление имени маршрута → экран.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract final class AppRouter {
  /// Создаёт маршрут по [settings.name]; аргументы извлекаются типизированно.
  ///
  /// [settings] — настройки маршрута; возвращает MaterialPageRoute.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget screen = switch (settings.name) {
      RouteNames.splash => const SplashScreen(),
      RouteNames.onboarding => const OnboardingScreen(),
      RouteNames.register => const RegistrationScreen(),
      RouteNames.login => const LoginScreen(),
      RouteNames.landing => const LandingScreen(),
      RouteNames.scheduleGame => const ScheduleGameScreen(),
      RouteNames.success => SuccessScreen(
        args:
            settings.arguments as SuccessRouteArgs? ??
            const SuccessRouteArgs('Готово'),
      ),
      RouteNames.combats => const DiscoverCombatsScreen(),
      RouteNames.combatInfo => CombatInformationScreen(
        args: settings.arguments as GameRouteArgs? ?? const GameRouteArgs(''),
      ),
      RouteNames.playerInfo => PlayerInformationScreen(
        args: settings.arguments as PlayerRouteArgs?,
      ),
      RouteNames.statistics => const StatisticsScreen(),
      RouteNames.gameImage => GameImageScreen(
        args: settings.arguments as GameRouteArgs? ?? const GameRouteArgs(''),
      ),
      RouteNames.gameCircle => GameCircleScreen(
        args: settings.arguments as GameRouteArgs? ?? const GameRouteArgs(''),
      ),
      RouteNames.privacyPolicy => const PrivacyPolicyScreen(),
      RouteNames.userAgreement => const UserAgreementScreen(),
      // Неизвестный маршрут → вход (безопасный дефолт).
      _ => const LoginScreen(),
    };

    return MaterialPageRoute<void>(builder: (_) => screen, settings: settings);
  }
}
