import '../api/auth_api.dart';
import '../api/games_api.dart';
import '../api/profile_api.dart';
import '../api/statistics_api.dart';
import '../config/api_config.dart';
import '../http/http_client.dart';
import '../http/response_parser.dart';
import '../transport/io_http_transport.dart';

/// Фасад библиотеки: собирает все API-группы и инфраструктуру (composition root).
///
/// Ответственность (SRP): только сборка объектов сетевого слоя.
/// Приложение работает через [NetworkClient] и абстракции API-интерфейсов.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class NetworkFactory {
  /// Создаёт REST-клиент на реальном HTTP-транспорте (dart:io).
  ///
  /// [config] — конфигурация API (base URL, таймауты, заголовки);
  /// [client] — готовый [HttpClient] (для тестов или мока),
  /// если не передан — создаётся [DartHttpClient] поверх [IoHttpTransport].
  static NetworkClient create({
    required ApiConfig config,
    HttpClient? client,
  }) {
    final httpClient = client ??
        DartHttpClient(
          transport: IoHttpTransport(
            connectTimeout: config.connectTimeout,
            receiveTimeout: config.receiveTimeout,
          ),
          baseUrl: config.baseUrl,
          defaultHeaders: config.defaultHeaders,
        );
    return _build(httpClient);
  }

  /// Собирает [NetworkClient] поверх произвольной абстракции [client].
  ///
  /// [client] — реализация HTTP-клиента (REST, mock, тестовая).
  static NetworkClient _build(HttpClient client) {
    final parser = ResponseParser();
    return NetworkClient(
      auth: RestAuthApi(client: client, parser: parser),
      profile: RestProfileApi(client: client, parser: parser),
      games: RestGamesApi(client: client, parser: parser),
      statistics: RestStatisticsApi(client: client, parser: parser),
    );
  }
}

/// Фасад сетевой библиотеки: группировка 11 API-операций по предметным
/// областям. Единственный объект, с которым работает слой data приложения.
///
/// Ответственность (SRP): предоставление доступа к API-группам.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class NetworkClient {
  /// Авторизация: вход, регистрация, выход.
  final AuthApi auth;

  /// Профиль: получение и изменение.
  final ProfileApi profile;

  /// Игры: создание, список, информация, подключение, результат.
  final GamesApi games;

  /// Статистика игрока.
  final StatisticsApi statistics;

  /// Создаёт фасад.
  ///
  /// [auth] — API авторизации; [profile] — API профиля;
  /// [games] — API игр; [statistics] — API статистики.
  const NetworkClient({
    required this.auth,
    required this.profile,
    required this.games,
    required this.statistics,
  });
}
