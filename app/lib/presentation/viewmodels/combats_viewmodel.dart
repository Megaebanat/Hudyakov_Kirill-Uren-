import '../../domain/entities/game.dart';
import '../../domain/usecases/get_games_use_case.dart';
import 'view_model.dart';

/// Фильтр списка игр на экране Discover Combats.
enum CombatsFilter {
  /// Все игры.
  all,

  /// Только предстоящие.
  upcoming,

  /// Только прошедшие.
  finished,
}

/// ViewModel экрана Discover Combats (список игр с фильтрами).
///
/// Ответственность (SRP): загрузка и фильтрация списка игр.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class CombatsViewModel extends ViewModel {
  final GetGamesUseCase _getGames;

  /// Все загруженные игры.
  List<Game> _games = const [];

  /// Активный фильтр.
  CombatsFilter filter = CombatsFilter.all;

  /// Данные загружались хоть раз.
  bool loaded = false;

  /// Создаёт ViewModel.
  ///
  /// [getGames] — use case списка игр.
  CombatsViewModel({required this._getGames});

  /// Игры после применения фильтра (новые вперёд).
  List<Game> get games {
    final source = switch (filter) {
      CombatsFilter.all => _games,
      CombatsFilter.upcoming =>
        _games
            .where(
              (game) =>
                  game.status == GameStatus.waiting ||
                  game.status == GameStatus.upcoming,
            )
            .toList(),
      CombatsFilter.finished =>
        _games.where((game) => game.status == GameStatus.finished).toList(),
    };
    return source;
  }

  /// Переключает фильтр [value].
  void setFilter(CombatsFilter value) {
    if (filter == value) return;
    filter = value;
    notifyListeners();
  }

  /// Загружает список игр с сервера.
  Future<void> load() async {
    final result = await guard<List<Game>>(
      tag: 'CombatsViewModel',
      event: 'Загрузка списка игр',
      action: _getGames.call,
    );
    if (result != null) {
      _games = result;
      loaded = true;
      notifyListeners();
    }
  }
}
