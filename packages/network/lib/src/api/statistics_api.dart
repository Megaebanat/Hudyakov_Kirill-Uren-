import '../dto/statistics_dto.dart';
import '../http/http_client.dart';
import '../http/response_parser.dart';

/// Абстракция запросов статистики игрока.
///
/// Ответственность (SRP): только получение статистики.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract interface class StatisticsApi {
  /// Статистика текущего игрока (очки, победы, созданные игры).
  Future<StatisticsDto> getStatistics();
}

/// Реализация [StatisticsApi] поверх абстрактного [HttpClient].
///
/// Ответственность (SRP): только эндпоинт статистики.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class RestStatisticsApi implements StatisticsApi {
  /// Абстрактный HTTP-клиент.
  final HttpClient client;

  /// Централизованный парсер ответов.
  final ResponseParser parser;

  /// Создаёт API статистики.
  ///
  /// [client] — HTTP-клиент; [parser] — парсер ответов.
  RestStatisticsApi({required this.client, required this.parser});

  @override
  Future<StatisticsDto> getStatistics() async {
    const path = '/statistics';
    final response = await client.get(path);
    final json = parser.asMap(
      parser.parse(
        rawBody: response.body,
        statusCode: response.statusCode,
        requestedPath: path,
      ),
      path,
    );
    return StatisticsDto.fromJson(json);
  }
}
