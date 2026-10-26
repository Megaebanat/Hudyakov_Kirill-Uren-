import '../dto/game_dto.dart';
import '../dto/game_result_dto.dart';
import '../http/http_client.dart';
import '../http/response_parser.dart';
import '../transport/http_request.dart';

/// Абстракция запросов игрового процесса.
///
/// Ответственность (SRP): создание игр, списки, информация, подключение,
/// сохранение результата.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract interface class GamesApi {
  /// Создание игры на сервере.
  ///
  /// [title] — название; [category] — категория (`image`/`circle`);
  /// [scheduledAt] — дата и время начала в формате ISO-8601.
  Future<GameDto> createGame({
    required String title,
    required String category,
    required String scheduledAt,
  });

  /// Получение списка всех игр (созданных и прошедших).
  Future<List<GameDto>> getGames();

  /// Получение детальной информации об игре [gameId].
  Future<GameDto> getGame(String gameId);

  /// Подключение текущего пользователя к игре [gameId].
  Future<GameDto> joinGame(String gameId);

  /// Сохранение результата игры [gameId] для [playerId].
  ///
  /// [durationMs] — затраченное время; [moves] — количество ходов;
  /// [completed] — собрана ли головоломка до конца.
  Future<void> saveResult({
    required String gameId,
    required String playerId,
    required int durationMs,
    required int moves,
    required bool completed,
  });
}

/// Реализация [GamesApi] поверх абстрактного [HttpClient].
///
/// Ответственность (SRP): только эндпоинты игрового процесса.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class RestGamesApi implements GamesApi {
  /// Абстрактный HTTP-клиент.
  final HttpClient client;

  /// Централизованный парсер ответов.
  final ResponseParser parser;

  /// Создаёт API игр.
  ///
  /// [client] — HTTP-клиент; [parser] — парсер ответов.
  RestGamesApi({required this.client, required this.parser});

  @override
  Future<GameDto> createGame({
    required String title,
    required String category,
    required String scheduledAt,
  }) async {
    final response = await client.post(
      '/games',
      body: {
        'title': title,
        'category': category,
        'scheduledAt': scheduledAt,
      },
    );
    return _gameFrom(response, '/games');
  }

  @override
  Future<List<GameDto>> getGames() async {
    final response = await client.get('/games');
    final list = parser.asList(
      parser.parse(
        rawBody: response.body,
        statusCode: response.statusCode,
        requestedPath: '/games',
      ),
      '/games',
    );
    return list
        .whereType<Map<String, Object?>>()
        .map(GameDto.fromJson)
        .toList();
  }

  @override
  Future<GameDto> getGame(String gameId) async {
    final response = await client.get('/games/$gameId');
    return _gameFrom(response, '/games/$gameId');
  }

  @override
  Future<GameDto> joinGame(String gameId) async {
    final response = await client.post('/games/$gameId/join');
    return _gameFrom(response, '/games/$gameId/join');
  }

  @override
  Future<void> saveResult({
    required String gameId,
    required String playerId,
    required int durationMs,
    required int moves,
    required bool completed,
  }) async {
    final path = '/games/$gameId/results';
    final response = await client.post(
      path,
      body: GameResultDto(
        gameId: gameId,
        playerId: playerId,
        durationMs: durationMs,
        moves: moves,
        completed: completed,
      ).toJson(),
    );
    parser.parse(
      rawBody: response.body,
      statusCode: response.statusCode,
      requestedPath: path,
    );
  }

  /// Разбирает ответ [response] в DTO игры ([path] — для сообщений ошибок).
  ///
  /// [response] — HTTP-ответ; [path] — путь запроса.
  GameDto _gameFrom(HttpResponse response, String path) {
    final json = parser.asMap(
      parser.parse(
        rawBody: response.body,
        statusCode: response.statusCode,
        requestedPath: path,
      ),
      path,
    );
    return GameDto.fromJson(json);
  }
}
