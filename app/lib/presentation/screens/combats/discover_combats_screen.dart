import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../../domain/usecases/get_games_use_case.dart';
import '../../mappers/game_card_mapper.dart';
import '../../navigation/route_args.dart';
import '../../navigation/route_names.dart';
import '../../viewmodels/combats_viewmodel.dart';
import '../widgets/game_list_tile.dart';
import '../widgets/screen_app_bar.dart';
import '../widgets/screen_lifecycle.dart';

/// Экран списка игр (Discover Combats) с фильтрами и обновлением.
///
/// Ответственность (SRP): отображение списка игр и переход к деталям.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class DiscoverCombatsScreen extends StatefulWidget {
  /// Создаёт экран списка игр.
  const DiscoverCombatsScreen({super.key});

  @override
  State<DiscoverCombatsScreen> createState() => _DiscoverCombatsScreenState();
}

/// Состояние списка игр: ViewModel, фильтры, состояния UI.
class _DiscoverCombatsScreenState extends State<DiscoverCombatsScreen>
    with ScreenLifecycle<DiscoverCombatsScreen> {
  @override
  String get screenName => 'DiscoverCombats';

  /// ViewModel списка.
  late final CombatsViewModel _vm;

  /// Зависимости созданы.
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;
    _vm = CombatsViewModel(
      getGames: GetGamesUseCase(AppScope.of(context).gameRepository),
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
    final games = _vm.games;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(title: 'Игры'),
      body: SafeArea(
        child: Column(
          children: [
            // Фильтры статуса.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  _filterChip(CombatsFilter.all, 'Все'),
                  const SizedBox(width: 8),
                  _filterChip(CombatsFilter.upcoming, 'Предстоящие'),
                  const SizedBox(width: 8),
                  _filterChip(CombatsFilter.finished, 'Завершённые'),
                ],
              ),
            ),
            Expanded(
              child: _vm.busy && !_vm.loaded
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _vm.load,
                      child: games.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 120),
                                _EmptyList(),
                              ],
                            )
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              itemCount: games.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final game = games[index];
                                return GameListTile(
                                  data: GameCardMapper.map(game),
                                  onTap: () => Navigator.of(context).pushNamed(
                                    RouteNames.combatInfo,
                                    arguments: GameRouteArgs(game.id),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Чип фильтра (с подсветкой активного).
  Widget _filterChip(CombatsFilter filter, String label) {
    final active = _vm.filter == filter;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _vm.setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: active ? AppColors.onPrimary : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Пустое состояние списка.
class _EmptyList extends StatelessWidget {
  /// Создаёт пустое состояние.
  const _EmptyList();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Icon(
        Icons.search_off_rounded,
        size: 56,
        color: AppColors.textSecondary,
      ),
      const SizedBox(height: 16),
      Text('Игры не найдены', style: AppTypography.h3),
      const SizedBox(height: 8),
      Text(
        'Измените фильтр или создайте новую игру',
        style: AppTypography.caption,
        textAlign: TextAlign.center,
      ),
    ],
  );
}
