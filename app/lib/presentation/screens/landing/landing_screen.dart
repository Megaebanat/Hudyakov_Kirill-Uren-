import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../../common/logging/app_logger.dart';
import '../../../domain/usecases/get_games_use_case.dart';
import '../../../domain/usecases/get_profile_use_case.dart';
import '../../../domain/usecases/sign_out_use_case.dart';
import '../../mappers/game_card_mapper.dart';
import '../../navigation/route_args.dart';
import '../../navigation/route_names.dart';
import '../../viewmodels/landing_viewmodel.dart';
import '../widgets/app_avatar.dart';
import '../widgets/game_list_tile.dart';
import '../widgets/screen_lifecycle.dart';

/// Основной экран (Landing): приветствие, игры сегодня, популярные игроки.
///
/// Анимированное боковое меню: гамбургер-кнопка (анимация), свайп вправо
/// открывает, свайп влево/крестик закрывает; центральная кнопка нижней
/// панели ведёт на Schedule Game (требование ТЗ).
///
/// Ответственность (SRP): хаб приложения и переходы по разделам.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class LandingScreen extends StatefulWidget {
  /// Создаёт основной экран.
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

/// Состояние Landing: ViewModel, боковое меню, список секций.
class _LandingScreenState extends State<LandingScreen>
    with ScreenLifecycle<LandingScreen>, SingleTickerProviderStateMixin {
  @override
  String get screenName => 'Landing';

  /// Анимация иконки гамбургер ↔ закрыть.
  late final AnimationController _menuController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  /// ViewModel экрана.
  late final LandingViewModel _vm;

  /// Зависимости созданы.
  bool _inited = false;

  /// Боковое меню открыто.
  bool _menuOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;
    final services = AppScope.of(context);
    _vm = LandingViewModel(
      getProfile: GetProfileUseCase(services.profileRepository),
      getGames: GetGamesUseCase(services.gameRepository),
      signOut: SignOutUseCase(services.authRepository),
    );
    _vm.addListener(_onVmChanged);
    _vm.load();
  }

  @override
  void dispose() {
    if (_inited) {
      _vm.removeListener(_onVmChanged);
      _vm.dispose();
    }
    _menuController.dispose();
    super.dispose();
  }

  /// Перерисовка по изменениям ViewModel (упрощённая подписка).
  void _onVmChanged() => setState(() {});

  /// Открывает/закрывает боковое меню с логом нажатия.
  void _toggleMenu({required bool open}) {
    AppLogger.info(
      'Landing',
      'Нажатие кнопки',
      open ? 'Меню открыто' : 'Меню закрыто',
    );
    if (open) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
    setState(() => _menuOpen = open);
  }

  /// Обработка свайпа: вправо — открыть, влево — закрыть.
  void _onSwipe(DragUpdateDetails details) {
    final dx = details.primaryDelta ?? 0;
    if (dx > 24 && !_menuOpen) {
      _toggleMenu(open: true);
    } else if (dx < -24 && _menuOpen) {
      _toggleMenu(open: false);
    }
  }

  /// Выход из аккаунта (пункт меню).
  Future<void> _signOut() async {
    AppLogger.info('Landing', 'Нажатие кнопки', '«Выйти»');
    await _vm.signOut();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(RouteNames.login, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      return const Scaffold(backgroundColor: AppColors.background);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Основной контент (свайп по нему управляет меню).
          GestureDetector(
            onHorizontalDragUpdate: _onSwipe,
            child: SafeArea(
              child: Column(
                children: [
                  _header(),
                  Expanded(
                    child: _vm.busy && _vm.games.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: _vm.load,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle('Сегодня'),
                                  const SizedBox(height: 12),
                                  ..._todayTiles(),
                                  const SizedBox(height: 28),
                                  _sectionTitle('Популярные игроки'),
                                  const SizedBox(height: 12),
                                  ..._playerTiles(),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Затемнение под меню.
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _menuOpen ? 1 : 0,
            child: IgnorePointer(
              ignoring: !_menuOpen,
              child: GestureDetector(
                onTap: () => _toggleMenu(open: false),
                child: Container(color: AppColors.scrim),
              ),
            ),
          ),
          // Боковое меню (анимация выезда).
          AnimatedSlide(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            offset: _menuOpen ? Offset.zero : const Offset(-1, 0),
            child: _sideMenu(),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomBar(
        items: const [
          AppBottomBarItem(icon: Icons.home_rounded, label: 'Главная'),
          AppBottomBarItem(icon: Icons.videogame_asset_rounded, label: 'Игры'),
          AppBottomBarItem(icon: Icons.insights_rounded, label: 'Статистика'),
          AppBottomBarItem(icon: Icons.person_rounded, label: 'Профиль'),
        ],
        currentIndex: 0,
        onChanged: (index) {
          switch (index) {
            case 1:
              AppLogger.info('Landing', 'Навигация', 'Discover Combats');
              Navigator.of(context).pushNamed(RouteNames.combats);
            case 2:
              AppLogger.info('Landing', 'Навигация', 'Statistics');
              Navigator.of(context).pushNamed(RouteNames.statistics);
            case 3:
              AppLogger.info('Landing', 'Навигация', 'Player Information');
              Navigator.of(context).pushNamed(
                RouteNames.playerInfo,
                arguments: PlayerRouteArgs(_vm.profile, isOwnProfile: true),
              );
            default:
              break;
          }
        },
        onCenterPressed: () {
          AppLogger.info(
            'Landing',
            'Нажатие кнопки',
            'Центральная кнопка → Schedule Game',
          );
          Navigator.of(context).pushNamed(RouteNames.scheduleGame);
        },
      ),
    );
  }

  /// Верхняя панель: гамбургер, заголовок, аватар.
  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Row(
      children: [
        IconButton(
          tooltip: _menuOpen ? 'Закрыть меню' : 'Открыть меню',
          onPressed: () => _toggleMenu(open: !_menuOpen),
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _menuController,
            size: 26,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Профессионалы',
            style: AppTypography.h3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => Navigator.of(context).pushNamed(
            RouteNames.playerInfo,
            arguments: PlayerRouteArgs(_vm.profile, isOwnProfile: true),
          ),
          child: AppAvatar(photoUrl: _vm.profile.photoUrl, size: 44),
        ),
      ],
    ),
  );

  /// Заголовок секции.
  Widget _sectionTitle(String text) => Text(text, style: AppTypography.h2);

  /// Карточки игр «Сегодня» (или пустое состояние).
  List<Widget> _todayTiles() {
    final today = _vm.todayGames;
    if (today.isEmpty) {
      return [_emptyCard('Сегодня игр нет', 'Создайте игру кнопкой «+» ниже')];
    }
    return [
      for (final game in today)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GameListTile(
            data: GameCardMapper.map(game),
            onTap: () => Navigator.of(context).pushNamed(
              RouteNames.combatInfo,
              arguments: GameRouteArgs(game.id),
            ),
          ),
        ),
    ];
  }

  /// Карточки популярных игроков (агрегация из игр).
  List<Widget> _playerTiles() {
    final players = _vm.popularPlayers;
    if (players.isEmpty) {
      return [_emptyCard('Игроков пока нет', 'Игры появятся после публикации')];
    }
    return [
      for (final player in players)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            onTap: () => Navigator.of(context).pushNamed(
              RouteNames.playerInfo,
              arguments: PlayerRouteArgs(player),
            ),
            child: Row(
              children: [
                AppAvatar(photoUrl: player.photoUrl, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        player.email,
                        style: AppTypography.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${player.rating}',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text('очков', style: AppTypography.caption),
                  ],
                ),
              ],
            ),
          ),
        ),
    ];
  }

  /// Пустое состояние секции.
  Widget _emptyCard(String title, String subtitle) => AppCard(
    child: Column(
      children: [
        const SizedBox(height: 4),
        Icon(Icons.inbox_rounded, size: 36, color: AppColors.textSecondary),
        const SizedBox(height: 10),
        Text(title, style: AppTypography.bodySmall),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTypography.caption,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  /// Боковое меню (профиль, разделы, выход).
  Widget _sideMenu() => Align(
    alignment: Alignment.centerLeft,
    child: FractionallySizedBox(
      heightFactor: 1,
      widthFactor: 0.78,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(right: BorderSide(color: AppColors.outline)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                child: Row(
                  children: [
                    AppAvatar(photoUrl: _vm.profile.photoUrl, size: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _vm.profile.name.isEmpty
                                ? 'Игрок'
                                : _vm.profile.name,
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _vm.profile.email,
                            style: AppTypography.caption,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Закрыть',
                      onPressed: () => _toggleMenu(open: false),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.outline),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _menuItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Профиль',
                      onTap: () {
                        _toggleMenu(open: false);
                        Navigator.of(context).pushNamed(
                          RouteNames.playerInfo,
                          arguments: PlayerRouteArgs(
                            _vm.profile,
                            isOwnProfile: true,
                          ),
                        );
                      },
                    ),
                    _menuItem(
                      icon: Icons.insights_rounded,
                      label: 'Статистика',
                      onTap: () {
                        _toggleMenu(open: false);
                        Navigator.of(context).pushNamed(RouteNames.statistics);
                      },
                    ),
                    _menuItem(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Политика конфиденциальности',
                      onTap: () {
                        _toggleMenu(open: false);
                        Navigator.of(context)
                            .pushNamed(RouteNames.privacyPolicy);
                      },
                    ),
                    _menuItem(
                      icon: Icons.description_outlined,
                      label: 'Пользовательское соглашение',
                      onTap: () {
                        _toggleMenu(open: false);
                        Navigator.of(context)
                            .pushNamed(RouteNames.userAgreement);
                      },
                    ),
                    const Divider(
                      height: 24,
                      color: AppColors.outline,
                      indent: 20,
                      endIndent: 20,
                    ),
                    _menuItem(
                      icon: Icons.logout_rounded,
                      label: 'Выйти',
                      danger: true,
                      onTap: _signOut,
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

  /// Пункт бокового меню.
  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      splashColor: AppColors.pressedOverlay,
    );
  }
}
