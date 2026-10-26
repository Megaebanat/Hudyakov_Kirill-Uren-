import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Компонент таймера обратного отсчёта.
///
/// Запускается автоматически (или по [startImmediately] == false), отображает
/// время в формате MM:SS и уведомляет через [onFinished], когда отсчёт
/// завершён. Управление таймером инкапсулировано внутри виджета (SRP).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppTimer extends StatefulWidget {
  /// Полная продолжительность отсчёта.
  final Duration duration;

  /// Вызывается один раз при завершении отсчёта.
  final VoidCallback? onFinished;

  /// Запускать отсчёт сразу после появления на экране.
  final bool startImmediately;

  /// Крупный режим (для полноэкранных игровых таймеров).
  final bool large;

  /// Создаёт таймер.
  ///
  /// [duration] — продолжительность; [onFinished] — завершение;
  /// [startImmediately] — автозапуск; [large] — крупный режим.
  const AppTimer({
    super.key,
    required this.duration,
    this.onFinished,
    this.startImmediately = true,
    this.large = false,
  });

  @override
  State<AppTimer> createState() => _AppTimerState();
}

/// Состояние таймера: остаток времени и подписка на тик.
///
/// Ответственность (SRP): отсчёт времени без привязки к бизнес-логике.
class _AppTimerState extends State<AppTimer> {
  /// Остаток отсчёта.
  late Duration _remaining = widget.duration;

  /// Периодический таймер тиков.
  Timer? _timer;

  /// Завершение уже объявлено (защита от повторного вызова).
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    if (widget.startImmediately) start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Запускает отсчёт, если он ещё не идёт.
  ///
  /// Без параметров и возвращаемого значения.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// Обрабатывает один тик секунды и завершает отсчёт на нуле.
  ///
  /// Без параметров и возвращаемого значения.
  void _tick() {
    if (_remaining.inSeconds <= 1) {
      _timer?.cancel();
      setState(() {
        _remaining = Duration.zero;
        if (!_finished) {
          _finished = true;
          // Колбэк вызывается после кадра, чтобы не менять дерево внутри build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onFinished?.call();
          });
        }
      });
    } else {
      setState(() => _remaining -= const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    final text =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Semantics(
      label: 'Таймер: $minutes минут $seconds секунд',
      child: Container(
        padding: widget.large
            ? const EdgeInsets.symmetric(horizontal: 22, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _remaining.inSeconds <= 10
                ? AppColors.error
                : AppColors.outline,
          ),
        ),
        child: Text(
          text,
          style: widget.large
              ? AppTypography.display.copyWith(
                  fontFeatures: const [],
                  color: _remaining.inSeconds <= 10
                      ? AppColors.error
                      : AppColors.textPrimary,
                )
              : AppTypography.h3.copyWith(
                  color: _remaining.inSeconds <= 10
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
        ),
      ),
    );
  }
}
