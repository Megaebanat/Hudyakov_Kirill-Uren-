import 'package:flutter/material.dart';

import '../../common/logging/app_logger.dart';
import '../../common/utils/email_validator.dart';
import '../../domain/entities/session.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';
import 'view_model.dart';

/// Режим авторизации ViewModel (вход или регистрация).
enum AuthMode {
  /// Экран входа (Login).
  login,

  /// Экран регистрации (Registration).
  register,
}

/// ViewModel экранов входа и регистрации (общая логика — DRY).
///
/// Управляет: поля формы, видимостью пароля, текстами ошибок валидации,
/// состоянием загрузки и отправкой формы. Валидация email выполняется по
/// паттерну `name@domain.ru` (только строчные буквы и цифры).
///
/// Ответственность (SRP): состояние и сценарии авторизационных форм.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AuthViewModel extends ViewModel {
  /// Режим работы (login/register).
  final AuthMode mode;

  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;

  /// Контроллеры полей (управляются экраном и освобождаются им же).
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  /// Показывать ли пароль открытым текстом.
  bool obscurePassword = true;

  /// Текст ошибки поля email (null — без ошибки).
  String? emailError;

  /// Текст ошибки поля пароля.
  String? passwordError;

  /// Текст ошибки поля имени (только регистрация).
  String? nameError;

  /// Создаёт ViewModel.
  ///
  /// [mode] — режим; [signIn] — use case входа; [signUp] — use case регистрации.
  AuthViewModel({
    required this.mode,
    required this._signIn,
    required this._signUp,
  }) {
    AppLogger.info(
      'AuthViewModel',
      'Жизненный цикл',
      'Создан (${mode == AuthMode.login ? 'вход' : 'регистрация'})',
    );
  }

  @override
  void dispose() {
    AppLogger.info(
      'AuthViewModel',
      'Жизненный цикл',
      'Уничтожен (${mode == AuthMode.login ? 'вход' : 'регистрация'})',
    );
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  /// Переключает видимость пароля.
  void toggleObscure() {
    obscurePassword = !obscurePassword;
    AppLogger.debug('AuthViewModel', 'Пароль', 'показать: $obscurePassword');
    notifyListeners();
  }

  /// Очищает тексты ошибок полей перед повторной отправкой.
  void _clearErrors() {
    emailError = null;
    passwordError = null;
    nameError = null;
  }

  /// Очищает ошибку поля email при новом вводе (ошибка исчезает по мере
  /// исправления).
  ///
  /// [value] — новый текст (не используется, сигнатура под ValueChanged).
  void onEmailChanged(String value) {
    if (emailError == null) return;
    emailError = null;
    notifyListeners();
  }

  /// Очищает ошибку поля имени при новом вводе.
  ///
  /// [value] — новый текст (не используется, сигнатура под ValueChanged).
  void onNameChanged(String value) {
    if (nameError == null) return;
    nameError = null;
    notifyListeners();
  }

  /// Выполняет сабмит формы; [onSuccess] вызывается с итоговой сессией.
  ///
  /// [onSuccess] — колбэк успешного входа/регистрации.
  Future<void> submit({
    required void Function(Session session) onSuccess,
  }) async {
    _clearErrors();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!EmailValidator.isValid(email)) {
      emailError = EmailValidator.errorText(email);
      notifyListeners();
      return;
    }
    if (password.isEmpty) {
      passwordError = 'Введите пароль';
      notifyListeners();
      return;
    }
    if (mode == AuthMode.register) {
      if (password.length < 6) {
        passwordError = 'Минимум 6 символов';
        notifyListeners();
        return;
      }
      if (nameController.text.trim().isEmpty) {
        nameError = 'Введите имя';
        notifyListeners();
        return;
      }
    }

    AppLogger.info(
      'AuthViewModel',
      'Нажатие кнопки',
      mode == AuthMode.login ? '«Вход» — $email' : '«Регистрация» — $email',
    );

    final session = await guard<Session>(
      tag: 'AuthViewModel',
      event: mode == AuthMode.login ? 'Авторизация' : 'Регистрация',
      action: () async => mode == AuthMode.login
          ? await _signIn(email, password)
          : await _signUp(
              email: email,
              password: password,
              name: nameController.text,
            ),
    );

    if (session != null) {
      AppLogger.info(
        'AuthViewModel',
        'Авторизация',
        'Успех для пользователя $email',
      );
      onSuccess(session);
    }
  }
}
