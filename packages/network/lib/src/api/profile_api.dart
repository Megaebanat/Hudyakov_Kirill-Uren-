import '../dto/auth_dto.dart';
import '../http/http_client.dart';
import '../http/response_parser.dart';

/// Абстракция запросов профиля пользователя.
///
/// Ответственность (SRP): получение и изменение данных профиля.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract interface class ProfileApi {
  /// Получение информации о профиле текущего пользователя.
  Future<UserProfileDto> getProfile();

  /// Изменение профиля (имя, фото, настройки уведомлений).
  ///
  /// [name] — новое имя (опционально);
  /// [photoUrl] — URL нового фото (опционально);
  /// [notificationsEnabled] — включить/выключить уведомления (опционально).
  Future<UserProfileDto> updateProfile({
    String? name,
    String? photoUrl,
    bool? notificationsEnabled,
  });
}

/// Реализация [ProfileApi] поверх абстрактного [HttpClient].
///
/// Ответственность (SRP): только эндпоинты профиля.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class RestProfileApi implements ProfileApi {
  /// Абстрактный HTTP-клиент.
  final HttpClient client;

  /// Централизованный парсер ответов.
  final ResponseParser parser;

  /// Создаёт API профиля.
  ///
  /// [client] — HTTP-клиент; [parser] — парсер ответов.
  RestProfileApi({required this.client, required this.parser});

  @override
  Future<UserProfileDto> getProfile() async {
    final response = await client.get('/profile');
    final json = parser.asMap(
      parser.parse(
        rawBody: response.body,
        statusCode: response.statusCode,
        requestedPath: '/profile',
      ),
      '/profile',
    );
    return UserProfileDto.fromJson(json);
  }

  @override
  Future<UserProfileDto> updateProfile({
    String? name,
    String? photoUrl,
    bool? notificationsEnabled,
  }) async {
    final body = <String, Object?>{
      if (name != null) 'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (notificationsEnabled != null)
        'notificationsEnabled': notificationsEnabled,
    };
    final response = await client.put('/profile', body: body);
    final json = parser.asMap(
      parser.parse(
        rawBody: response.body,
        statusCode: response.statusCode,
        requestedPath: '/profile',
      ),
      '/profile',
    );
    return UserProfileDto.fromJson(json);
  }
}
