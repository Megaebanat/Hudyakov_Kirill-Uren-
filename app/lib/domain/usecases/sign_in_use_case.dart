import '../../common/utils/email_validator.dart';
import '../errors/domain_exception.dart';
import '../repositories/auth_repository.dart';
import '../entities/session.dart';

/// Use case: вход пользователя в систему.
///
/// Ответственность (SRP): валидация ввода и координация входа.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class SignInUseCase {
  /// Репозиторий аутентификации (зависимость направлена на абстракцию — DIP).
  final AuthRepository repository;

  /// Создаёт use case.
  ///
  /// [repository] — репозиторий аутентификации.
  SignInUseCase(this.repository);

  /// Выполняет вход.
  ///
  /// [email] — почта; [password] — пароль; возвращает [Session].
  /// Бросает [ValidationException] при некорректном вводе,
  /// [DomainException] — при ошибке авторизации на сервере.
  Future<Session> call(String email, String password) async {
    if (!EmailValidator.isValid(email)) {
      throw const ValidationException('Некорректный email: name@domain.ru');
    }
    if (password.isEmpty) {
      throw const ValidationException('Введите пароль');
    }
    return repository.signIn(email: email, password: password);
  }
}
