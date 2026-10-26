/// Доменная сущность «Пользователь» (чистая бизнес-модель без зависимостей).
///
/// Ответственность (SRP): описание профиля игрока в системе.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppUser {
  /// Идентификатор пользователя.
  final String id;

  /// Email пользователя.
  final String email;

  /// Отображаемое имя.
  final String name;

  /// URL фотографии профиля (null — не задана).
  final String? photoUrl;

  /// Рейтинг/очки игрока.
  final int rating;

  /// Пользователь хочет получать локальные уведомления об играх.
  final bool notificationsEnabled;

  /// Создаёт пользователя.
  ///
  /// [id] — идентификатор; [email] — почта; [name] — имя;
  /// [photoUrl] — фото; [rating] — очки; [notificationsEnabled] — уведомления.
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.rating = 0,
    this.notificationsEnabled = false,
  });

  /// Пользователь с пустыми данными (до загрузки профиля).
  static const AppUser empty = AppUser(id: '', email: '', name: '');

  /// Возвращает копию с изменёнными полями.
  ///
  /// [name] — новое имя; [photoUrl] — новое фото; [rating] — очки;
  /// [notificationsEnabled] — флаг уведомлений.
  AppUser copyWith({
    String? name,
    String? photoUrl,
    int? rating,
    bool? notificationsEnabled,
  }) => AppUser(
    id: id,
    email: email,
    name: name ?? this.name,
    photoUrl: photoUrl ?? this.photoUrl,
    rating: rating ?? this.rating,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
  );
}
