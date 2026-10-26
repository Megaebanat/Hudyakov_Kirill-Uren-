import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../navigation/route_args.dart';
import '../../navigation/route_names.dart';
import '../widgets/screen_lifecycle.dart';

/// Экран подтверждения успешной публикации (Success).
///
/// Ответственность (SRP): показ результата действия и возврат на главный
/// экран.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class SuccessScreen extends StatefulWidget {
  /// Аргументы экрана (текст подтверждения).
  final SuccessRouteArgs args;

  /// Создаёт экран успеха.
  ///
  /// [args] — аргументы маршрута.
  const SuccessScreen({super.key, required this.args});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

/// Состояние экрана успеха: анимация появления галочки.
class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin, ScreenLifecycle<SuccessScreen> {
  @override
  String get screenName => 'Success';

  /// Аниматор появления (масква от 0.6 к 1).
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  /// Кривая оживления.
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 72,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                widget.args.message,
                style: AppTypography.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Результат сохранён. Вы можете вернуться к играм '
                'или создать новое соревнование.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: 'На главную',
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(RouteNames.landing, (route) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
