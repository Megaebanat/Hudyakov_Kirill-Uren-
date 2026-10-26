import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../navigation/route_names.dart';
import '../widgets/screen_lifecycle.dart';

/// Экран запуска (Splash): краткий показ логотипа и решение о маршруте.
///
/// Логика выбора первого экрана:
/// 1) приветствие ещё не показывалось → Onboarding;
/// 2) нет валидной сессии → Login;
/// 3) иначе — восстановление последнего экрана (состояние после перезапуска).
///
/// Ответственность (SRP): стартовая заставка и стартовое решение навигации.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class SplashScreen extends StatefulWidget {
  /// Создаёт экран запуска.
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// Состояние Splash: таймер показа и выбор маршрута.
class _SplashScreenState extends State<SplashScreen>
    with ScreenLifecycle<SplashScreen> {
  @override
  String get screenName => 'Splash';

  /// Таймер автоперехода.
  Timer? _timer;

  /// Решение уже принято (защита от повторного перехода).
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Решение принимается один раз после инициализации зависимостей.
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1600), _decideRoute);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Вычисляет стартовый маршрут и выполняет переход (pushReplacement).
  void _decideRoute() {
    if (_navigated || !mounted) return;
    _navigated = true;

    final services = AppScope.of(context);
    final route = _resolveRoute(
      onboardingShown: services.prefsStore.onboardingShown,
      hasSession: services.sessionStore.restore().token.isNotEmpty,
      lastRoute: services.prefsStore.lastRoute,
    );

    Navigator.of(context).pushReplacementNamed(route);
  }

  /// Чистая функция выбора маршрута (выделяется для тестируемости).
  ///
  /// [onboardingShown] — приветствие показано; [hasSession] — есть сессия;
  /// [lastRoute] — последний экран; возвращает имя маршрута.
  static String _resolveRoute({
    required bool onboardingShown,
    required bool hasSession,
    required String? lastRoute,
  }) {
    if (!onboardingShown) return RouteNames.onboarding;
    if (!hasSession) return RouteNames.login;
    if (lastRoute != null && RouteNames.restorable.contains(lastRoute)) {
      return lastRoute;
    }
    return RouteNames.landing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                size: 52,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text('Профессионалы', style: AppTypography.h1),
            const SizedBox(height: 8),
            Text(
              'Турниры по головоломкам',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
