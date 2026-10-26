import 'app_user.dart';

/// Доменная сущность «Сессия»: токен и вошедший пользователь.
///
/// Ответственность (SRP): описание состояния авторизованного входа.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class Session {
  /// Токен доступа (Bearer), сохраняется локально.
  final String token;

  /// Профиль вошедшего пользователя.
  final AppUser user;

  /// Создаёт сессию.
  ///
  /// [token] — токен; [user] — пользователь.
  const Session({required this.token, required this.user});

  /// Сессия отсутствует (пользователь не вошёл).
  static const Session none = Session(token: '', user: AppUser.empty);

  /// Пользователь авторизован (непустой токен).
  bool get isValid => token.isNotEmpty;
}
