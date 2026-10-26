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

/// Экран игры «Картинка»: сборка изображения 3×3 из фрагментов в лотке.
///
/// Изображение детерминировано по gameId — все игроки одной игры собирают
/// одну и ту же картинку (требование ТЗ). Игра завершается автоматически
/// при полной сборке; досрочный выход фиксируется как поражение.
///
/// Ответственность (SRP): UI игрового поля «Картинка».
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GameImageScreen extends StatefulWidget {
  /// Аргументы маршрута (идентификатор игры).
  final GameRouteArgs args;

  /// Создаёт экран игры.
  ///
  /// [args] — аргументы маршрута.
  const GameImageScreen({super.key, required this.args});

  @override
  State<GameImageScreen> createState() => _GameImageScreenState();
}

/// Состояние игры: ViewModel поля, таймер, диалоги завершения.
class _GameImageScreenState extends State<GameImageScreen>
    with ScreenLifecycle<GameImageScreen> {
  @override
  String get screenName => 'GameImage';

  /// Путь к локальному изображению игры.
  late final String _asset;

  /// ViewModel игры.
  late final ImageGameViewModel _vm;

  /// Зависимости созданы.
  bool _inited = false;

  /// Диалог результата уже показан.
  bool _resultShown = false;

  /// Подписка на ViewModel.
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
    final index = ImageGameViewModel.imageIndexFor(widget.args.gameId);
    _asset = 'assets/images/puzzle_${index + 1}.png';
    _vm = ImageGameViewModel(
      gameId: widget.args.gameId,
      player: services.sessionStore.restore().user,
      saveResult: SaveGameResultUseCase(services.gameRepository),
      analytics: services.analytics,
    );
    _vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    if (_inited) {
      _vm.removeListener(_onVmChanged);
      _vm.dispose();
    }
    super.dispose();
  }

  /// Диалог завершения: победа (сборка) или истёкшее время.
  Future<void> _showFinishDialog({required bool won}) async {
    AppLogger.info(
      'GameImage',
      'Диалог результата',
      won ? 'Сборка завершена' : 'Время вышло',
    );
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          won ? 'Головоломка собрана!' : 'Время вышло',
          style: AppTypography.h3,
        ),
        content: Text(
          won
              ? 'Отличная работа! Ходов: ${_vm.moves}, '
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
        title: 'Картинка',
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
              // Панель: эталон, таймер, ходы.
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: _tileThumb(id: 4, size: 56),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Соберите изображение',
                          style: AppTypography.label,
                        ),
                        const SizedBox(height: 6),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Поле 3×3.
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cell = (constraints.maxWidth - 12) / 3;
                        return GridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for (var i = 0; i < 9; i++) _cell(i, cell),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Фрагменты', style: AppTypography.label),
              const SizedBox(height: 8),
              // Лоток фрагментов.
              SizedBox(
                height: 74,
                child: _vm.tray.isEmpty
                    ? Center(
                        child: Text(
                          'Все фрагменты расставлены',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _vm.tray.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) => SizedBox(
                          width: 66,
                          height: 66,
                          child: _trayTile(_vm.tray[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Чип-контейнер панели.
  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.outline),
    ),
    child: Text(text, style: AppTypography.caption),
  );

  /// Ячейка поля (пустая либо с фрагментом).
  Widget _cell(int index, double size) {
    final tile = _vm.cells[index];
    final correct = tile == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: tile != null ? null : () => _vm.placeTile(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: tile == null ? AppColors.surfaceAlt : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: tile == null
                ? AppColors.outline
                : (correct ? AppColors.success : AppColors.outline),
            width: tile != null && correct ? 2 : 1,
          ),
        ),
        child: tile == null
            ? const Icon(
                Icons.add_rounded,
                color: AppColors.disabledText,
                size: 22,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: _tileThumb(id: tile, size: size),
              ),
      ),
    );
  }

  /// Фрагмент в лотке (с подсветкой выбора).
  Widget _trayTile(int tile) {
    final selected = _vm.selectedTile == tile;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _vm.selectTile(tile),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outline,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: _tileThumb(id: tile, size: 60),
        ),
      ),
    );
  }

  /// Обрезка изображения до фрагмента [id] (строка/столбец 3×3).
  ///
  /// [id] — номер фрагмента (0..8); [size] — размер квадрата.
  Widget _tileThumb({required int id, required double size}) {
    final row = id ~/ 3;
    final col = id % 3;
    return SizedBox(
      width: size,
      height: size,
      child: OverflowBox(
        minWidth: 0,
        minHeight: 0,
        maxWidth: size * 3,
        maxHeight: size * 3,
        alignment: Alignment((-1 + col).toDouble(), (-1 + row).toDouble()),
        child: Image.asset(
          _asset,
          width: size * 3,
          height: size * 3,
          fit: BoxFit.fill,
          errorBuilder: (_, _, _) => Container(
            color: AppColors.surfaceAlt,
            alignment: Alignment.center,
            child: Text(
              '${id + 1}',
              style: AppTypography.h3.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
