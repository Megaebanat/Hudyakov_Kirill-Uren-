import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../../common/logging/app_logger.dart';
import '../../../domain/usecases/save_game_result_use_case.dart';
import '../../navigation/route_args.dart';
import '../../viewmodels/game_viewmodel.dart';
import '../widgets/elapsed_timer.dart';
import '../widgets/screen_app_bar.dart';
import '../widgets/screen_lifecycle.dart';

/// Экран игры «Круг»: нажатие кругов от большего к меньшему.
///
/// Поле и размеры кругов детерминированы по gameId (одинаковое поле для
/// всех игроков). Неверное нажатие подсвечивается на короткое время и
/// засчитывается как ход. Игра завершается автоматически после сборки
/// всех кругов; досрочный выход — поражение.
///
/// Ответственность (SRP): UI игрового поля «Круг».
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GameCircleScreen extends StatefulWidget {
  /// Аргументы маршрута (идентификатор игры).
  final GameRouteArgs args;

  /// Создаёт экран игры.
  ///
  /// [args] — аргументы маршрута.
  const GameCircleScreen({super.key, required this.args});

  @override
  State<GameCircleScreen> createState() => _GameCircleScreenState();
}

/// Состояние игры: ViewModel, таймер подсветки, диалоги завершения.
class _GameCircleScreenState extends State<GameCircleScreen>
    with ScreenLifecycle<GameCircleScreen> {
  @override
  String get screenName => 'GameCircle';

  /// ViewModel игры.
  late final CircleGameViewModel _vm;

  /// Зависимости созданы.
  bool _inited = false;

  /// Диалог результата показан.
  bool _resultShown = false;

  /// Таймер сброса подсветки неверного круга.
  Timer? _wrongTimer;

  /// Подписка на изменения ViewModel.
  void _onVmChanged() {
    if (!mounted) return;
    setState(() {});
    if (_vm.finished && !_resultShown) {
      _resultShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showFinishDialog(won: true);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;
    final services = AppScope.of(context);
    _vm = CircleGameViewModel(
      gameId: widget.args.gameId,
      player: services.sessionStore.restore().user,
      saveResult: SaveGameResultUseCase(services.gameRepository),
      analytics: services.analytics,
    );
    _vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    _wrongTimer?.cancel();
    if (_inited) {
      _vm.removeListener(_onVmChanged);
      _vm.dispose();
    }
    super.dispose();
  }

  /// Нажатие на круг: обработка и временная подсветка ошибки.
  void _onTap(int circleId) {
    _vm.tapCircle(circleId);
    if (_vm.wrongCircleId != null) {
      _wrongTimer?.cancel();
      _wrongTimer = Timer(const Duration(milliseconds: 450), () {
        if (mounted) _vm.clearWrong();
      });
    }
  }

  /// Диалог завершения: победа или истёкшее время.
  Future<void> _showFinishDialog({required bool won}) async {
    AppLogger.info(
      'GameCircle',
      'Диалог результата',
      won ? 'Все круга собраны' : 'Время вышло',
    );
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          won ? 'Все круга собраны!' : 'Время вышло',
          style: AppTypography.h3,
        ),
        content: Text(
          won
              ? 'Порядок соблюден! Ходов: ${_vm.moves}, '
                    'время: ${_vm.elapsedLabel}.'
              : 'Игра окончена без сборки — результат сохранён.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              won ? 'Продолжить' : 'Выйти',
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (won || !mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScreenAppBar(
        title: 'Круг',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: ElapsedTimer(label: () => _vm.elapsedLabel)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Панель управления.
              Row(
                children: [
                  AppTimer(
                    duration: const Duration(minutes: 5),
                    onFinished: () {
                      if (!_vm.finished && !_resultShown) {
                        _resultShown = true;
                        _showFinishDialog(won: false);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _chip('Ходов: ${_vm.moves}'),
                  const SizedBox(width: 8),
                  _chip(
                    'Собрано: ${_vm.collected.length}/'
                    '${_vm.circles.length}',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Нажимайте круги от большего к меньшему',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              // Игровое поле.
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;
                      return Stack(
                        children: [
                          for (final circle in _vm.circles)
                            if (!_vm.collected.contains(circle.id))
                              Positioned(
                                left: circle.fx * w - circle.size / 2,
                                top: circle.fy * h - circle.size / 2,
                                child: _circle(circle),
                              ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Собранные круга (в порядке сборки).
              Text('Собранные', style: AppTypography.label),
              const SizedBox(height: 8),
              SizedBox(
                height: 70,
                child: _vm.collected.isEmpty
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Пока ни одного — начните с самого большого',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final id in _vm.collected)
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _miniCircle(
                                    _vm.circles.firstWhere((c) => c.id == id),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Чип панели управления.
  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.outline),
    ),
    child: Text(text, style: AppTypography.caption),
  );

  /// Круг на поле с подсветкой ожидаемого и подсветкой ошибки.
  Widget _circle(GameCircle circle) {
    final isExpected = circle.id == _vm.expectedId;
    final isWrong = _vm.wrongCircleId == circle.id;
    final color = isWrong
        ? AppColors.error
        : (isExpected ? AppColors.primary : AppColors.secondary);
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => _onTap(circle.id),
      child: AnimatedContainer(
        duration: Duration(milliseconds: isWrong ? 80 : 220),
        width: circle.size,
        height: circle.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: isExpected ? 0.34 : 0.22),
          border: Border.all(
            color: color,
            width: isWrong || isExpected ? 2.5 : 1.5,
          ),
        ),
        child: Icon(
          isWrong ? Icons.close_rounded : Icons.circle_outlined,
          color: color,
          size: circle.size * 0.4,
        ),
      ),
    );
  }

  /// Уменьшённый круг в полосе «Собранные».
  Widget _miniCircle(GameCircle circle) {
    final size = circle.size * 0.6;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.success.withValues(alpha: 0.2),
        border: Border.all(color: AppColors.success, width: 1.5),
      ),
      child: Icon(
        Icons.check_rounded,
        size: size * 0.4,
        color: AppColors.success,
      ),
    );
  }
}
