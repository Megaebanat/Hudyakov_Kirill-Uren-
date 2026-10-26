import 'dart:async';
import 'dart:math';

import '../../common/logging/app_logger.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_result.dart';
import '../../domain/usecases/save_game_result_use_case.dart';
import '../../services/analytics/analytics_service.dart';
import 'view_model.dart';

/// Базовый ViewModel игровой сессии (общее для обеих категорий).
///
/// Управляет: таймером сессии, счётчиком ходов, отправкой результата на
/// сервер и событиями аналитики. Собрал головоломку → completed = true;
/// игрок закрыл игру до завершения → completed = false (поражение, ТЗ).
///
/// Ответственность (SRP): жизненный цикл игровой сессии и результат.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GameViewModel extends ViewModel {
  /// Идентификатор игры.
  final String gameId;

  /// Категория игры.
  final GameCategory category;

  /// Игрок, играющий сессию.
  final AppUser player;

  final SaveGameResultUseCase _saveResult;
  final AnalyticsService _analytics;

  /// Момент старта сессии.
  final DateTime startedAt = DateTime.now();

  /// Количество выполненных ходов.
  int moves = 0;

  /// Головоломка собрана (сессия завершена успешно).
  bool finished = false;

  bool _resultSent = false;

  /// Создаёт базовый ViewModel сессии.
  ///
  /// [gameId] — игра; [category] — категория; [player] — игрок;
  /// [saveResult] — отправка результата; [analytics] — аналитика.
  GameViewModel({
    required this.gameId,
    required this.category,
    required this.player,
    required this._saveResult,
    required this._analytics,
  }) {
    AppLogger.info(
      'GameViewModel',
      'Жизненный цикл',
      'Сессия начата ($gameId, ${category.name})',
    );
    _analytics.logEvent(
      'game_started',
      parameters: {'game_id': gameId, 'category': category.name},
    );
  }

  /// Длительность сессии с момента старта.
  Duration get elapsed => DateTime.now().difference(startedAt);

  /// Форматированный таймер elapsed (мм:сс).
  String get elapsedLabel {
    final total = elapsed.inSeconds;
    final minutes = (total ~/ 60).toString().padLeft(2, '0');
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Регистрирует ход (увеличивает счётчик).
  void registerMove() {
    moves++;
    notifyListeners();
  }

  /// Отправляет результат на сервер (однократно).
  ///
  /// [completed] — собрана ли головоломка.
  Future<void> _sendResult({required bool completed}) async {
    if (_resultSent) return;
    _resultSent = true;
    await guard<void>(
      tag: 'GameViewModel',
      event: 'Сохранение результата игры',
      action: () => _saveResult(
        GameResult(
          gameId: gameId,
          playerId: player.id,
          durationMs: elapsed.inMilliseconds,
          moves: moves,
          completed: completed,
        ),
      ),
    );
    AppLogger.info(
      'GameViewModel',
      'Сохранение результата игры',
      'completed: $completed, ходов: $moves',
    );
  }

  /// Завершает игру успешно (головоломка собрана): результат + аналитика.
  Future<void> completePuzzle() async {
    if (finished) return;
    finished = true;
    AppLogger.info(
      'GameViewModel',
      'Игра завершена',
      '$gameId — сборка завершена, ходов: $moves',
    );
    await _analytics.logEvent(
      'game_completed',
      parameters: {'game_id': gameId, 'moves': moves},
    );
    await _sendResult(completed: true);
    notifyListeners();
  }

  /// Досрочный выход из игры = поражение (требование модуля Г).
  Future<void> abandon() async {
    if (finished || _resultSent) return;
    AppLogger.info(
      'GameViewModel',
      'Игра закрыта досрочно',
      '$gameId — поражение (игрок вышел)',
    );
    await _analytics.logEvent(
      'game_abandoned',
      parameters: {'game_id': gameId},
    );
    await _sendResult(completed: false);
  }

  @override
  void dispose() {
    AppLogger.info(
      'GameViewModel',
      'Жизненный цикл',
      'Сессия уничтожена ($gameId)',
    );
    if (!finished) {
      // Гарантия: закрытие игры без сборки всегда фиксируется как поражение.
      unawaited(abandon());
    }
    super.dispose();
  }
}

/// ViewModel игры «Картинка» (3×3 из 9 фрагментов одного изображения).
///
/// Изображение выбирается детерминированно из gameId — все игроки одной
/// игры собирают одну и ту же картинку. Раскладка фрагментов перемешивается
/// сидом от gameId (воспроизводимо).
///
/// Ответственность (SRP): состояние поля и логика раскладки фрагментов.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class ImageGameViewModel extends GameViewModel {
  /// Количество клеток поля (3×3).
  static const int gridSize = 9;

  /// Ячейки поля: id фрагмента или null (пусто).
  /// Правильная раскладка — фрагмент id лежит в клетке id.
  final List<int?> cells = List<int?>.filled(gridSize, null);

  /// Фрагменты, оставшиеся в лотке.
  late final List<int> tray;

  /// Выбранный в лотке фрагмент (null — не выбран).
  int? selectedTile;

  /// Создаёт ViewModel игры «Картинка».
  ///
  /// [gameId] — игра; [player] — игрок; [saveResult] — отправка результата;
  /// [analytics] — аналитика.
  ImageGameViewModel({
    required super.gameId,
    required super.player,
    required super.saveResult,
    required super.analytics,
  }) : super(category: GameCategory.image) {
    final random = Random(gameId.hashCode);
    tray = List<int>.generate(gridSize, (i) => i)..shuffle(random);
    AppLogger.debug(
      'ImageGameViewModel',
      'Поле создано',
      'ид игры: $gameId, сид: ${gameId.hashCode}',
    );
  }

  /// Индекс локального изображения для этой игры (одинаков для всех игроков).
  static int imageIndexFor(String gameId) => gameId.hashCode.abs() % 4;

  /// Все клетки заполнены верно (головоломка собрана).
  bool get isComplete =>
      cells.asMap().entries.every((entry) => entry.value == entry.key);

  /// Выбирает фрагмент [tileId] в лотке.
  void selectTile(int tileId) {
    if (finished) return;
    selectedTile = tileId;
    AppLogger.debug('ImageGameViewModel', 'Фрагмент выбран', 'id: $tileId');
    _analyticsLog('puzzle_tile_selected', {'tile': tileId});
    notifyListeners();
  }

  /// Ставит выбранный фрагмент в клетку [cellIndex]; обновляет счётчик ходов,
  /// при полной сборке автоматически завершает игру.
  void placeTile(int cellIndex) {
    if (finished) return;
    final tile = selectedTile;
    if (tile == null || cells[cellIndex] != null) return;

    cells[cellIndex] = tile;
    selectedTile = null;
    tray.remove(tile);
    registerMove();

    final correct = cellIndex == tile;
    AppLogger.debug(
      'ImageGameViewModel',
      'Фрагмент установлен',
      'клетка: $cellIndex, корректно: $correct',
    );
    _analyticsLog('puzzle_tile_placed', {
      'cell': cellIndex,
      'correct': correct,
      'moves': moves,
    });

    if (isComplete) {
      unawaited(completePuzzle());
    } else {
      notifyListeners();
    }
  }

  /// Лог аналитики без ожидания (события Яндекс Метрики в игре «Картинка»).
  void _analyticsLog(String name, Map<String, Object?> parameters) {
    unawaited(_logAnalytics(name, parameters));
  }

  Future<void> _logAnalytics(
    String name,
    Map<String, Object?> parameters,
  ) async {
    try {
      await _analytics.logEvent(name, parameters: parameters);
    } catch (error, stackTrace) {
      AppLogger.error(
        'ImageGameViewModel',
        'Аналитика — ошибка',
        error,
        stackTrace,
      );
    }
  }
}

/// Круг игрового поля игры «Круг».
class GameCircle {
  /// Идентификатор круга (0..count-1).
  final int id;

  /// Диаметр (px) — по нему определяется порядок сборки.
  final double size;

  /// Доля центра по горизонтали (0..1) внутри поля.
  final double fx;

  /// Доля центра по вертикали (0..1) внутри поля.
  final double fy;

  /// Создаёт круг.
  const GameCircle({
    required this.id,
    required this.size,
    required this.fx,
    required this.fy,
  });
}

/// ViewModel игры «Круг»: нужно нажимать круги от большего к меньшему.
///
/// Круги и их позиции детерминированно зависят от gameId (одинаковое поле
/// для всех игроков игры). Неверное нажатие фиксируется и добавляет ход.
///
/// Ответственность (SRP): состояние поля и порядок сборки кругов.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class CircleGameViewModel extends GameViewModel {
  /// Все круги поля (перемешаны, размеры уникальны).
  final List<GameCircle> circles;

  /// Собраннные круга (в порядке сборки).
  final List<int> collected = <int>[];

  /// id круга, на который нажали неверно (для анимации тряски; null — ок).
  int? wrongCircleId;

  late final List<int> _bySizeDesc;

  /// Создаёт ViewModel игры «Круг».
  ///
  /// [gameId] — игра; [player] — игрок; [saveResult] — отправка результата;
  /// [analytics] — аналитика.
  CircleGameViewModel({
    required super.gameId,
    required super.player,
    required super.saveResult,
    required super.analytics,
  }) : circles = _buildCircles(gameId),
       super(category: GameCategory.circle) {
    final bySize = List<GameCircle>.from(circles)
      ..sort((a, b) => b.size.compareTo(a.size));
    _bySizeDesc = bySize.map((circle) => circle.id).toList();

    AppLogger.debug(
      'CircleGameViewModel',
      'Поле создано',
      'ид игры: $gameId, кругов: ${circles.length}',
    );
  }

  /// Детерминированно строит круги и их позиции из [gameId]
  /// (одинаковое поле для всех игроков одной игры).
  static List<GameCircle> _buildCircles(String gameId) {
    final random = Random(gameId.hashCode);
    const sizes = [96.0, 80.0, 66.0, 54.0, 44.0, 36.0];
    // Фиксированные точки рассеивания, затем перемешивание кругов по сиду.
    const spots = [
      (0.22, 0.24),
      (0.68, 0.20),
      (0.45, 0.46),
      (0.18, 0.72),
      (0.75, 0.66),
      (0.48, 0.82),
    ];
    final order = List<int>.generate(sizes.length, (i) => i)..shuffle(random);

    return List<GameCircle>.generate(sizes.length, (i) {
      final source = order[i];
      return GameCircle(
        id: i,
        size: sizes[source],
        fx: spots[i].$1,
        fy: spots[i].$2,
      );
    });
  }

  /// Ожидаемый следующий круг (от большего к меньшему).
  int get expectedId =>
      collected.length < circles.length ? _bySizeDesc[collected.length] : -1;

  /// Все круга собраны (игра завершена).
  bool get isComplete => collected.length == circles.length;

  /// Нажатие на круг [circleId]: верно → собирает, иначе → фиксирует ошибку.
  void tapCircle(int circleId) {
    if (finished || collected.contains(circleId)) return;
    wrongCircleId = null;

    if (circleId == expectedId) {
      collected.add(circleId);
      registerMove();
      AppLogger.debug(
        'CircleGameViewModel',
        'Круг собран',
        'id: $circleId, порядок: ${collected.length}/${circles.length}',
      );
      if (isComplete) {
        unawaited(completePuzzle());
        return;
      }
    } else {
      wrongCircleId = circleId;
      registerMove();
      AppLogger.debug(
        'CircleGameViewModel',
        'Неверный круг',
        'нажат: $circleId, ожидается: $expectedId',
      );
    }
    notifyListeners();
  }

  /// Сбрасывает подсветку неверного круга (вызывается экраном через таймер).
  void clearWrong() {
    if (wrongCircleId == null) return;
    wrongCircleId = null;
    notifyListeners();
  }
}
