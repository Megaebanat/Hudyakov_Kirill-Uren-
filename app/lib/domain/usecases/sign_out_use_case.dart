import '../repositories/auth_repository.dart';

/// Use case: выход пользователя (завершение сессии).
///
/// Ответственность (SRP): единственный сценарий выхода.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class SignOutUseCase {
  /// Репозиторий аутентификации (абстракция — DIP).
  final AuthRepository repository;

  /// Создаёт use case.
  ///
  /// [repository] — репозиторий аутентификации.
  SignOutUseCase(this.repository);

  /// Завершает сессию (локальную и на сервере).
  ///
  /// Без параметров; возвращает Future завершения.
  Future<void> call() => repository.signOut();
}
