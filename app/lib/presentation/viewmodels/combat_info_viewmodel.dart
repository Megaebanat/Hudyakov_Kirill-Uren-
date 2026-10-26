import '../../common/logging/app_logger.dart';
import '../../domain/entities/game.dart';
import '../../domain/usecases/get_game_use_case.dart';
import '../../domain/usecases/join_game_use_case.dart';
import 'view_model.dart';

/// ViewModel экрана Combat Information (детальная информация + подключение).
///
/// Ответственность (SRP): загрузка одной игры и сценарий подключения.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class CombatInfoViewModel extends ViewModel {
  final GetGameUseCase _getGame;
  final JoinGameUseCase _joinGame;

  /// Идентификатор игры.
  final String gameId;

  /// Загруженная игра (null — ещё не загружена).
  Game? game;

  /// Создаёт ViewModel.
  ///
  /// [gameId] — игра; [getGame] — загрузка; [joinGame] — подключение.
  CombatInfoViewModel({
    required this.gameId,
    required this._getGame,
    required this._joinGame,
  });

  /// Загружает детальную информацию об игре.
  Future<void> load() async {
    final result = await guard<Game>(
      tag: 'CombatInfoViewModel',
      event: 'Загрузка информации об игре',
      action: () => _getGame(gameId),
    );
    if (result != null) {
      game = result;
      AppLogger.debug(
        'CombatInfoViewModel',
        'Загрузка информации об игре',
        '${result.title} (${result.status.name})',
      );
      notifyListeners();
    }
  }

  /// Подключается к игре; [onJoined] вызывается с обновлённой игрой.
  ///
  /// [currentUserId] — id вошедшего пользователя; [onJoined] — колбэк успеха.
  Future<void> join({
    required String currentUserId,
    required void Function(Game game) onJoined,
  }) async {
    final current = game;
    if (current == null) return;
    AppLogger.info(
      'CombatInfoViewModel',
      'Нажатие кнопки',
      '«Подключиться к игре» — ${current.id}',
    );

    final result = await guard<Game>(
      tag: 'CombatInfoViewModel',
      event: 'Подключение к игре',
      action: () =>
          _joinGame(gameId, isCreator: current.createdBy(currentUserId)),
    );
    if (result != null) {
      game = result;
      AppLogger.info(
        'CombatInfoViewModel',
        'Подключение к игре',
        'Успех: ${result.title}',
      );
      notifyListeners();
      onJoined(result);
    }
  }
}
