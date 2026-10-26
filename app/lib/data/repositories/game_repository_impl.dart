import '../../common/logging/app_logger.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/prefs_store.dart';
import '../datasources/remote_api_data_source.dart';
import '../mappers/error_mapper.dart';
import '../mappers/game_mapper.dart';

/// Реализация [GameRepository]: REST API + локальный кэш списка игр.
///
/// Кэш в [PrefsStore] позволяет восстановить экран после перезапуска
/// приложения (состояние последнего экрана сохраняется — модуль Г).
///
/// Ответственность (SRP): сценарии игрового процесса.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GameRepositoryImpl implements GameRepository {
  /// Удалённый источник данных.
  final RemoteApiDataSource _api;

  /// Локальное хранилище (кэш игр и состояние экранов).
  final PrefsStore _prefs;

  /// Создаёт реализацию.
  ///
  /// [api] — удалённый источник; [prefs] — хранилище настроек.
  GameRepositoryImpl({required this._api, required this._prefs});

  @override
  Future<Game> createGame({
    required String title,
    required GameCategory category,
    required DateTime scheduledAt,
  }) async {
    try {
      AppLogger.info(
        'GameRepository',
        'Создание игры',
        '«$title» (${category.name}) на ${scheduledAt.toIso8601String()}',
      );
      final dto = await _api.createGame(
        title: title,
        category: category.name,
        scheduledAt: scheduledAt.toIso8601String(),
      );
      final game = GameMapper.toEntity(dto);
      AppLogger.info('GameRepository', 'Создание игры', 'Успех: ${game.id}');
      return game;
    } catch (error, stackTrace) {
      AppLogger.error(
        'GameRepository',
        'Создание игры — ошибка',
        error,
        stackTrace,
      );
      throw ErrorMapper.map(error);
    }
  }

  @override
  Future<List<Game>> getGames() async {
    try {
      AppLogger.info(
        'GameRepository',
        'Загрузка списка игр',
        'Запрос отправлен',
      );
      final dtos = await _api.getGames();
      final games = dtos.map(GameMapper.toEntity).toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
      await _prefs.saveGamesCache(games);
      AppLogger.debug(
        'GameRepository',
        'Загрузка списка игр',
        'Получено: ${games.length}',
      );
      return games;
    } catch (error, stackTrace) {
      AppLogger.error(
        'GameRepository',
        'Загрузка списка игр — ошибка',
        error,
        stackTrace,
      );
      throw ErrorMapper.map(error);
    }
  }

  @override
  Future<Game> getGame(String gameId) async {
    try {
      AppLogger.info('GameRepository', 'Загрузка игры', 'id=$gameId');
      final dto = await _api.getGame(gameId);
      final game = GameMapper.toEntity(dto);
      AppLogger.debug(
        'GameRepository',
        'Загрузка игры',
        'Успех: ${game.title}',
      );
      return game;
    } catch (error, stackTrace) {
      AppLogger.error(
        'GameRepository',
        'Загрузка игры — ошибка',
        error,
        stackTrace,
      );
      throw ErrorMapper.map(error);
    }
  }

  @override
  Future<Game> joinGame(String gameId) async {
    try {
      AppLogger.info('GameRepository', 'Подключение к игре', 'id=$gameId');
      final dto = await _api.joinGame(gameId);
      final game = GameMapper.toEntity(dto);
      AppLogger.info(
        'GameRepository',
        'Подключение к игре',
        'Успех: ${game.title}',
      );
      return game;
    } catch (error, stackTrace) {
      AppLogger.error(
        'GameRepository',
        'Подключение к игре — ошибка',
        error,
        stackTrace,
      );
      throw ErrorMapper.map(error);
    }
  }

  @override
  Future<void> saveResult(GameResult result) async {
    try {
      AppLogger.info(
        'GameRepository',
        'Сохранение результата игры',
        'game=${result.gameId}, время=${result.durationMs}мс, '
            'ходы=${result.moves}, собрана=${result.completed}',
      );
      await _api.saveResult(
        gameId: result.gameId,
        playerId: result.playerId,
        durationMs: result.durationMs,
        moves: result.moves,
        completed: result.completed,
      );
      AppLogger.debug('GameRepository', 'Сохранение результата игры', 'Успех');
    } catch (error, stackTrace) {
      AppLogger.error(
        'GameRepository',
        'Сохранение результата — ошибка',
        error,
        stackTrace,
      );
      throw ErrorMapper.map(error);
    }
  }
}
