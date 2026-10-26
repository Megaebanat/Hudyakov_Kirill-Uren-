import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../../domain/entities/player_statistics.dart';
import '../../../domain/usecases/get_profile_use_case.dart';
import '../../../domain/usecases/get_statistics_use_case.dart';
import '../../viewmodels/statistics_viewmodel.dart';
import '../widgets/screen_app_bar.dart';
import '../widgets/screen_lifecycle.dart';

/// Экран статистики (Statistics).
///
/// Блоки: THIS WEEK EARNINGS, PLAYED GAMES (победы «Круг» — синий,
/// «Картинка» — красный), SCHEDULED GAMES (созданные игры недели).
///
/// Ответственность (SRP): отображение агрегированных показателей игрока.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class StatisticsScreen extends StatefulWidget {
  /// Создаёт экран статистики.
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

/// Состояние экрана статистики.
class _StatisticsScreenState extends State<StatisticsScreen>
    with ScreenLifecycle<StatisticsScreen> {
  @override
  String get screenName => 'Statistics';

  /// ViewModel экрана.
  late final StatisticsViewModel _vm;

  /// Зависимости созданы.
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;
    final services = AppScope.of(context);
    _vm = StatisticsViewModel(
      getStatistics: GetStatisticsUseCase(services.statisticsRepository),
      getProfile: GetProfileUseCase(services.profileRepository),
    );
    _vm.addListener(() => setState(() {}));
    _vm.load();
  }

  @override
  void dispose() {
    if (_inited) _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    final stats = _vm.statistics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(title: 'Статистика'),
      body: SafeArea(
        child: _vm.busy && stats == PlayerStatistics.empty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _vm.load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _vm.profile.name.isEmpty
                            ? 'Игрок'
                            : 'Статистика игрока ${_vm.profile.name}',
                        style: AppTypography.h3,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Рейтинг: ${_vm.profile.rating} очков',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // THIS WEEK EARNINGS.
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryPressed,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THIS WEEK EARNINGS',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Icon(
                                  Icons.stars_rounded,
                                  size: 36,
                                  color: AppColors.onPrimary,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${stats.weekEarnings}',
                                  style: AppTypography.display.copyWith(
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'очков',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Played Games', style: AppTypography.h2),
                      const SizedBox(height: 12),
                      // Победы по категориям.
                      Row(
                        children: [
                          Expanded(
                            child: _winCard(
                              color: AppColors.secondary,
                              icon: Icons.circle_rounded,
                              label: 'Круг',
                              value: stats.circleWins,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _winCard(
                              color: AppColors.accentRed,
                              icon: Icons.image_rounded,
                              label: 'Image',
                              value: stats.imageWins,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Scheduled Games', style: AppTypography.h2),
                      const SizedBox(height: 12),
                      AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.16,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.event_rounded,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Создано за неделю',
                                style: AppTypography.bodySmall,
                              ),
                            ),
                            Text(
                              '${stats.scheduledGames}',
                              style: AppTypography.h2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.16,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.emoji_events_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Всего сыграно побед',
                                style: AppTypography.bodySmall,
                              ),
                            ),
                            Text(
                              '${stats.totalWins}',
                              style: AppTypography.h2.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// Карточка побед категории.
  Widget _winCard({
    required Color color,
    required IconData icon,
    required String label,
    required int value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text('$value', style: AppTypography.h1.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
