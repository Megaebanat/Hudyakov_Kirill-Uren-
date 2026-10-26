import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

/// Счётчик затраченного времени игровой сессии (тикает раз в секунду).
///
/// Отображает нарастающее время в формате MM:SS; значение читается из
/// замыкания [label] (источник — игровой ViewModel).
///
/// Ответственность (SRP): периодическое обновление текста времени.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class ElapsedTimer extends StatefulWidget {
  /// Функция получения текущей метки времени.
  final String Function() label;

  /// Создаёт счётчик времени.
  ///
  /// [label] — источник текста метки.
  const ElapsedTimer({super.key, required this.label});

  @override
  State<ElapsedTimer> createState() => _ElapsedTimerState();
}

/// Состояние счётчика: периодический таймер и перерисовка текста.
class _ElapsedTimerState extends State<ElapsedTimer> {
  /// Периодический таймер.
  Timer? _timer;

  /// Текущий текст метки.
  late String _text = widget.label();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _text = widget.label());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            _text,
            style: AppTypography.h3.copyWith(
              fontFeatures: const [],
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
