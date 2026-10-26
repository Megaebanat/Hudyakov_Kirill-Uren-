import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../../common/logging/app_logger.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/usecases/create_game_use_case.dart';
import '../../navigation/route_args.dart';
import '../../navigation/route_names.dart';
import '../../viewmodels/schedule_game_viewmodel.dart';
import '../widgets/screen_app_bar.dart';
import '../widgets/screen_lifecycle.dart';

/// Экран планирования игры (Schedule Game).
///
/// Нативные диалоги даты и времени (showDatePicker/showTimePicker),
/// селект категории через BottomSheet, чекбокс локального уведомления,
/// публикация на сервере → Success → Landing.
///
/// Ответственность (SRP): форма создания игры.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class ScheduleGameScreen extends StatefulWidget {
  /// Создаёт экран планирования.
  const ScheduleGameScreen({super.key});

  @override
  State<ScheduleGameScreen> createState() => _ScheduleGameScreenState();
}

/// Состояние формы планирования игры.
class _ScheduleGameScreenState extends State<ScheduleGameScreen>
    with ScreenLifecycle<ScheduleGameScreen> {
  @override
  String get screenName => 'ScheduleGame';

  /// ViewModel формы.
  late final ScheduleGameViewModel _vm;

  /// Зависимости созданы.
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;
    final services = AppScope.of(context);
    _vm = ScheduleGameViewModel(
      createGame: CreateGameUseCase(services.gameRepository),
      notifications: services.notifications,
    );
    _vm.addListener(() => setState(() {}));
    AppLogger.info('ScheduleGame', 'Жизненный цикл', 'Форма создания игры');
  }

  @override
  void dispose() {
    if (_inited) _vm.dispose();
    super.dispose();
  }

  /// Нативный диалог выбора даты.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _vm.date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null && mounted) _vm.setDate(picked);
  }

  /// Нативный диалог выбора времени.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _vm.time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked != null && mounted) _vm.setTime(picked);
  }

  /// Публикация: на Success (заменяет текущий маршрут).
  Future<void> _publish() async {
    await _vm.publish(
      onSuccess: (game) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(
          RouteNames.success,
          arguments: SuccessRouteArgs('Игра «${game.title}» опубликована!'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(title: 'Новая игра'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _vm.titleController,
                label: 'Название игры',
                hint: 'Например: Вечерний турнир',
                errorText: _vm.titleError,
                enabled: !_vm.busy,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.title_rounded, size: 20),
                onChanged: _vm.setTitle,
              ),
              const SizedBox(height: 24),
              AppSelect<GameCategory>(
                label: 'Категория',
                hint: 'Выберите головоломку',
                value: _vm.category,
                enabled: !_vm.busy,
                items: const [
                  SelectItem(
                    value: GameCategory.image,
                    label: 'Картинка',
                    icon: Icons.image_outlined,
                  ),
                  SelectItem(
                    value: GameCategory.circle,
                    label: 'Круг',
                    icon: Icons.circle_outlined,
                  ),
                ],
                onChanged: _vm.setCategory,
              ),
              const SizedBox(height: 24),
              Text('Дата и время', style: AppTypography.label),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _pickerTile(
                      icon: Icons.calendar_today_outlined,
                      label: 'Дата',
                      value: _vm.date == null
                          ? 'Не выбрана'
                          : '${_vm.date!.day.toString().padLeft(2, '0')}.'
                                '${_vm.date!.month.toString().padLeft(2, '0')}.'
                                '${_vm.date!.year}',
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pickerTile(
                      icon: Icons.schedule_rounded,
                      label: 'Время',
                      value: _vm.time == null
                          ? 'Не выбрано'
                          : _vm.time!.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              if (_vm.formError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _vm.formError!,
                  style: AppTypography.caption.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 20),
              AppCard(
                child: AppCheckbox(
                  value: _vm.notifyBeforeGame,
                  label: 'Напомнить за час до начала (локальное уведомление)',
                  onChanged: _vm.setNotify,
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Опубликовать',
                loading: _vm.busy,
                onPressed: _vm.busy ? null : _publish,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Плитка выбора даты/времени.
  Widget _pickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _vm.busy ? null : onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.caption),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTypography.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
