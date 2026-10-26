/// Публичный API библиотеки сетевого слоя.
///
/// Библиотека спроектирована как независимый модуль:
///  * изолированность — самостоятельный проект со собственным pubspec;
///  * абстрагированность — приложение работает через интерфейсы
///    ([HttpClient], [AuthApi], [ProfileApi], [GamesApi], [StatisticsApi]),
///    а не через конкретную реализацию;
///  * заменяемость — реализацию ([DartHttpClient]) можно заменить на другую
///    (Dio, Fetch и т.п.) без изменения кода основного приложения;
///  * независимое версионирование — semver, собственный жизненный цикл.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
library;

export 'src/api/auth_api.dart';
export 'src/api/games_api.dart';
export 'src/api/profile_api.dart';
export 'src/api/statistics_api.dart';
export 'src/config/api_config.dart';
export 'src/dto/auth_dto.dart';
export 'src/dto/error_dto.dart';
export 'src/dto/game_dto.dart';
export 'src/dto/game_result_dto.dart';
export 'src/dto/statistics_dto.dart';
export 'src/errors/network_exception.dart';
export 'src/factory/network_factory.dart';
export 'src/http/authenticated_http_client.dart';
export 'src/http/http_client.dart';
export 'src/http/response_parser.dart';
export 'src/mock/mock_http_client.dart';
export 'src/transport/http_request.dart';
export 'src/transport/http_transport.dart';
export 'src/transport/io_http_transport.dart';
