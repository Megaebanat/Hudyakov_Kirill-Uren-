import '../entities/session.dart';

/// Абстракция репозитория аутентификации (контракт для presentation/domain).
///
/// Ответственность (SRP): вход, регистрация, выход.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract interface class AuthRepository {
  /// Вход по email/паролю; сохраняет сессию локально.
  ///
  /// [email] — почта; [password] — пароль.
  /// Бросает [DomainException] при ошибке.
  Future<Session> signIn({required String email, required String password});

  /// Регистрация нового пользователя; сохраняет сессию локально.
  ///
  /// [email] — почта; [password] — пароль; [name] — отображаемое имя.
  Future<Session> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// Выход: завершает сессию на сервере и очищает локальную.
  Future<void> signOut();
}
