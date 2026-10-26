import '../../domain/entities/app_user.dart';
import '../../domain/entities/game.dart';
import '../../domain/usecases/get_games_use_case.dart';
import '../../domain/usecases/get_profile_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import 'view_model.dart';

/// ViewModel основного экрана (Landing): профиль, игры, популярные игроки.
///
/// «Most Popular Players» вычисляется из участников игр (по убыванию очков) —
/// отдельный эндпоинт в API отсутствует, поэтому агрегация выполняется
/// на клиенте (DRY: переиспользуются данные игр).
///
/// Ответственность (SRP): данные экрана Landing и выход из аккаунта.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class LandingViewModel extends ViewModel {
  final GetProfileUseCase _getProfile;
  final GetGamesUseCase _getGames;
  final SignOutUseCase _signOut;

  /// Профиль текущего пользователя (до загрузки — пустой).
  AppUser profile = AppUser.empty;

  /// Все загруженные игры.
  List<Game> games = const [];

  /// Создаёт ViewModel.
  ///
  /// [getProfile] — загрузка профиля; [getGames] — список игр;
  /// [signOut] — выход.
  LandingViewModel({
    required this._getProfile,
    required this._getGames,
    required this._signOut,
  });

  /// Игры, назначенные сегодня (блок «Сегодня»).
  List<Game> get todayGames {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return games.where((game) {
      final day = DateTime(
        game.scheduledAt.year,
        game.scheduledAt.month,
        game.scheduledAt.day,
      );
      return day == today && game.status != GameStatus.finished;
    }).toList()..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  /// Популярные игроки: уникальные участники игр по убыванию очков (до 5).
  List<AppUser> get popularPlayers {
    final byId = <String, AppUser>{};
    for (final game in games) {
      byId[game.creator.id] = game.creator;
      final opponent = game.opponent;
      if (opponent != null) byId[opponent.id] = opponent;
    }
    final players = byId.values.toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return players.take(5).toList();
  }

  /// Загружает профиль и список игр; ошибки показываются глобальным
  /// уведомлением через [guard].
  Future<void> load() async {
    final loadedProfile = await guard<AppUser>(
      tag: 'LandingViewModel',
      event: 'Загрузка профиля',
      action: _getProfile.call,
    );
    if (loadedProfile != null) profile = loadedProfile;

    final loadedGames = await guard<List<Game>>(
      tag: 'LandingViewModel',
      event: 'Загрузка игр',
      action: _getGames.call,
    );
    if (loadedGames != null) games = loadedGames;
    notifyListeners();
  }

  /// Выходит из аккаунта (вызов — из бокового меню).
  Future<void> signOut() => guard<void>(
    tag: 'LandingViewModel',
    event: 'Выход из аккаунта',
    action: _signOut.call,
  );
}
