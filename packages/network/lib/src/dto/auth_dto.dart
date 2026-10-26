/// DTO моделей аутентификации и профиля, приходящих от сервера.
///
/// Ответственность (SRP): описание сетевых моделей данных (Data layer),
/// преобразование в доменные сущности выполняется маппером приложения.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
library;

/// Профиль пользователя в формате сервера.
class UserProfileDto {
  /// Идентификатор пользователя.
  final String id;

  /// Email пользователя.
  final String email;

  /// Отображаемое имя.
  final String name;

  /// URL аватара (может быть null, если не задан).
  final String? photoUrl;

  /// Рейтинг/очки игрока.
  final int rating;

  /// Локальное уведомление о предстоящей игре включено.
  final bool notificationsEnabled;

  /// Создаёт DTO профиля.
  ///
  /// [id] — идентификатор; [email] — почта; [name] — имя;
  /// [photoUrl] — URL фото; [rating] — очки;
  /// [notificationsEnabled] — флаг уведомлений.
  const UserProfileDto({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.rating = 0,
    this.notificationsEnabled = false,
  });

  /// Разбирает DTO из JSON-объекта [json].
  factory UserProfileDto.fromJson(Map<String, Object?> json) => UserProfileDto(
        id: '${json['id']}',
        email: '${json['email'] ?? ''}',
        name: '${json['name'] ?? ''}',
        photoUrl: json['photoUrl'] as String?,
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      );

  /// Сериализует DTO в JSON.
  Map<String, Object?> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'rating': rating,
        'notificationsEnabled': notificationsEnabled,
      };

  /// Возвращает копию с изменёнными полями (неизменённые берутся из текущего).
  UserProfileDto copyWith({
    String? name,
    String? photoUrl,
    int? rating,
    bool? notificationsEnabled,
  }) =>
      UserProfileDto(
        id: id,
        email: email,
        name: name ?? this.name,
        photoUrl: photoUrl ?? this.photoUrl,
        rating: rating ?? this.rating,
        notificationsEnabled:
            notificationsEnabled ?? this.notificationsEnabled,
      );
}

/// Ответ сервера после входа/регистрации.
class AuthResponseDto {
  /// Токен доступа (хранится в локальной сессии).
  final String token;

  /// Данные вошедшего пользователя.
  final UserProfileDto user;

  /// Создаёт DTO авторизации.
  ///
  /// [token] — токен сессии; [user] — профиль пользователя.
  const AuthResponseDto({required this.token, required this.user});

  /// Разбирает DTO из JSON [json].
  factory AuthResponseDto.fromJson(Map<String, Object?> json) => AuthResponseDto(
        token: '${json['token'] ?? ''}',
        user: UserProfileDto.fromJson(
          (json['user'] as Map<String, Object?>?) ?? const {},
        ),
      );

  /// Сериализует DTO в JSON.
  Map<String, Object?> toJson() => {'token': token, 'user': user.toJson()};
}
