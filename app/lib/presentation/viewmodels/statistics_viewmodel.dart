import '../../domain/entities/app_user.dart';
import '../../domain/entities/player_statistics.dart';
import '../../domain/usecases/get_profile_use_case.dart';
import '../../domain/usecases/get_statistics_use_case.dart';
import 'view_model.dart';

/// ViewModel экрана Statistics.
///
/// Загружает агрегаты недели (THIS WEEK EARNINGS), победы по категориям
/// (Played Games: синий круг / красный Image) и созданные игры
/// (Scheduled Games), а также профиль для заголовка.
///
/// Ответственность (SRP): данные экрана статистики.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class StatisticsViewModel extends ViewModel {
  final GetStatisticsUseCase _getStatistics;
  final GetProfileUseCase _getProfile;

  /// Статистика (до загрузки — пустая).
  PlayerStatistics statistics = PlayerStatistics.empty;

  /// Профиль игрока (для заголовка и рейтинга).
  AppUser profile = AppUser.empty;

  /// Создаёт ViewModel.
  ///
  /// [getStatistics] — статистика; [getProfile] — профиль.
  StatisticsViewModel({
    required this._getStatistics,
    required this._getProfile,
  });

  /// Загружает статистику и профиль.
  Future<void> load() async {
    final stats = await guard<PlayerStatistics>(
      tag: 'StatisticsViewModel',
      event: 'Загрузка статистики',
      action: _getStatistics.call,
    );
    if (stats != null) statistics = stats;

    final user = await guard<AppUser>(
      tag: 'StatisticsViewModel',
      event: 'Загрузка профиля',
      action: _getProfile.call,
    );
    if (user != null) profile = user;
    notifyListeners();
  }
}
