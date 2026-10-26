import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../../common/utils/formatters.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/game.dart';
import '../../../domain/usecases/get_game_use_case.dart';
import '../../../domain/usecases/join_game_use_case.dart';
import '../../navigation/route_args.dart';
import '../../navigation/route_names.dart';
import '../../viewmodels/combat_info_viewmodel.dart';
import '../widgets/app_avatar.dart';
import '../widgets/screen_app_bar.dart';
import '../widgets/screen_lifecycle.dart';

/// Экран детальной информации об игре (Combat Information).
///
/// Показывает состав, дату, категорию; позволяет подключиться к игре и
/// запустить подходящую головоломку (своё участие определяет доступность).
///
/// Ответственность (SRP): детали одной игры и действия над ней.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class CombatInformationScreen extends StatefulWidget {
  /// Аргументы маршрута (идентификатор игры).
  final GameRouteArgs args;

  /// Создаёт экран деталей игры.
  ///
  /// [args] — аргументы маршрута.
  const CombatInformationScreen({super.key, required this.args});

  @override
  State<CombatInformationScreen> createState() =>
      _CombatInformationScreenState();
}

/// Состояние экрана деталей игры.
class _CombatInformationScreenState extends State<CombatInformationScreen>
    with ScreenLifecycle<CombatInformationScreen> {
  @override
  String get screenName => 'CombatInformation';

  /// ViewModel экрана.
  late final CombatInfoViewModel _vm;

  /// Идентификатор текущего пользователя.
  late final String _currentUserId;

  /// Зависимости созданы.
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;
    final services = AppScope.of(context);
    _currentUserId = services.sessionStore.restore().user.id;
    _vm = CombatInfoViewModel(
      gameId: widget.args.gameId,
      getGame: GetGameUseCase(services.gameRepository),
      joinGame: JoinGameUseCase(services.gameRepository),
    );
    _vm.addListener(() => setState(() {}));
    _vm.load();
  }

  @override
  void dispose() {
    if (_inited) _vm.dispose();
    super.dispose();
  }

  /// Подключение к игре.
  Future<void> _join() async {
    await _vm.join(
      currentUserId: _currentUserId,
      onJoined: (_) {
        if (mounted) setState(() {});
      },
    );
  }

  /// Запуск головоломки по категории игры.
  void _startGame(Game game) {
    final route = game.category == GameCategory.circle
        ? RouteNames.gameCircle
        : RouteNames.gameImage;
    Navigator.of(context).pushNamed(route, arguments: GameRouteArgs(game.id));
  }

  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    final game = _vm.game;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(title: 'Об игре'),
      body: SafeArea(
        child: game == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(game),
                    const SizedBox(height: 20),
                    _infoCard(game),
                    const SizedBox(height: 16),
                    _playerCard('Создатель', game.creator),
                    const SizedBox(height: 12),
                    game.opponent == null
                        ? _waitingCard()
                        : _playerCard('Соперник', game.opponent!),
                    const SizedBox(height: 28),
                    _actions(game),
                  ],
                ),
              ),
      ),
    );
  }

  /// Заголовок с иконкой категории и статусом.
  Widget _header(Game game) {
    final isCircle = game.category == GameCategory.circle;
    final accent = isCircle ? AppColors.secondary : AppColors.accentRed;
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            isCircle ? Icons.circle_outlined : Icons.image_outlined,
            size: 32,
            color: accent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(game.title, style: AppTypography.h2),
              const SizedBox(height: 6),
              Text(
                Formatters.gameDateTime(game.scheduledAt),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Карточка характеристик игры.
  Widget _infoCard(Game game) => AppCard(
    child: Column(
      children: [
        _infoRow(
          Icons.category_outlined,
          'Категория',
          game.category == GameCategory.circle ? 'Круг' : 'Картинка',
        ),
        const Divider(height: 24, color: AppColors.outline),
        _infoRow(
          Icons.event_available_outlined,
          'Статус',
          switch (game.status) {
            GameStatus.waiting => 'Ожидает соперника',
            GameStatus.upcoming => 'Назначена',
            GameStatus.inProgress => 'Идёт сейчас',
            GameStatus.finished => 'Завершена',
          },
        ),
        const Divider(height: 24, color: AppColors.outline),
        _infoRow(
          Icons.access_time_rounded,
          'Начало',
          Formatters.gameDateTime(game.scheduledAt),
        ),
      ],
    ),
  );

  /// Строка характеристики.
  Widget _infoRow(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, size: 20, color: AppColors.textSecondary),
      const SizedBox(width: 12),
      Text(
        label,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      const Spacer(),
      Flexible(
        child: Text(
          value,
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  /// Карточка игрока (переход к Player Information).
  Widget _playerCard(String role, AppUser player) => AppCard(
    onTap: () => Navigator.of(context)
        .pushNamed(RouteNames.playerInfo, arguments: PlayerRouteArgs(player)),
    child: Row(
      children: [
        AppAvatar(photoUrl: player.photoUrl, size: 48),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                player.name.isEmpty ? 'Не указано' : player.name,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ],
    ),
  );

  /// Заглушка «ожидает соперника».
  Widget _waitingCard() => AppCard(
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_add_alt_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Соперник ещё не подключился',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );

  /// Кнопки действий: подключение / запуск игры.
  Widget _actions(Game game) {
    final participates = game.containsPlayer(_currentUserId);
    final canJoin = !participates && game.status == GameStatus.waiting;

    if (participates && game.status != GameStatus.finished) {
      return AppButton(
        label: game.category == GameCategory.circle
            ? 'Играть: Круг'
            : 'Играть: Картинка',
        icon: Icons.play_arrow_rounded,
        onPressed: () => _startGame(game),
      );
    }
    if (canJoin) {
      return AppButton(
        label: 'Подключиться к игре',
        icon: Icons.login_rounded,
        loading: _vm.busy,
        onPressed: _vm.busy ? null : _join,
      );
    }
    return AppButton(
      label: game.status == GameStatus.finished
          ? 'Игра завершена'
          : 'Вы уже участвуете',
      onPressed: null,
    );
  }
}
