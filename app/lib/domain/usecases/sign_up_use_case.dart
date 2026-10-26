import '../../common/utils/email_validator.dart';
import '../entities/session.dart';
import '../errors/domain_exception.dart';
import '../repositories/auth_repository.dart';

/// Use case: регистрация нового пользователя.
///
/// Ответственность (SRP): валидация регистрационной формы и координация
/// регистрации.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class SignUpUseCase {
  /// Репозиторий аутентификации (абстракция — DIP).
  final AuthRepository repository;

  /// Создаёт use case.
  ///
  /// [repository] — репозиторий аутентификации.
  SignUpUseCase(this.repository);

  /// Выполняет регистрацию.
  ///
  /// [email] — почта; [password] — пароль; [name] — имя;
  /// возвращает [Session]. Бросает [ValidationException] при ошибке валидации.
  Future<Session> call({
    required String email,
    required String password,
    required String name,
  }) async {
    if (!EmailValidator.isValid(email)) {
      throw const ValidationException('Некорректный email: name@domain.ru');
    }
    if (password.length < 6) {
      throw const ValidationException(
        'Пароль должен содержать минимум 6 символов',
      );
    }
    if (name.trim().isEmpty) {
      throw const ValidationException('Введите имя');
    }
    return repository.signUp(
      email: email,
      password: password,
      name: name.trim(),
    );
  }
}
