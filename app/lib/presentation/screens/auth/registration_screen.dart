import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../../common/logging/app_logger.dart';
import '../../../domain/usecases/sign_in_use_case.dart';
import '../../../domain/usecases/sign_up_use_case.dart';
import '../../navigation/route_names.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/screen_app_bar.dart';
import '../widgets/screen_lifecycle.dart';

/// Экран регистрации (Registration).
///
/// Фиксированная нижняя кнопка «Создать аккаунт», валидация email по
/// паттерну `name@domain.ru` (строчные буквы и цифры), показ/скрытие пароля,
/// чекбокс согласия со Соглашением и Политикой (документы открываются).
///
/// Ответственность (SRP): форма регистрации.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class RegistrationScreen extends StatefulWidget {
  /// Создаёт экран регистрации.
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

/// Состояние экрана регистрации.
class _RegistrationScreenState extends State<RegistrationScreen>
    with ScreenLifecycle<RegistrationScreen> {
  @override
  String get screenName => 'Registration';

  /// ViewModel формы регистрации.
  late final AuthViewModel _vm;

  /// Соглашение принято (кнопка активна только при true).
  bool _agreed = false;

  /// Зависимости созданы.
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;
    final services = AppScope.of(context);
    _vm = AuthViewModel(
      mode: AuthMode.register,
      signIn: SignInUseCase(services.authRepository),
      signUp: SignUpUseCase(services.authRepository),
    );
  }

  @override
  void dispose() {
    if (_inited) _vm.dispose();
    super.dispose();
  }

  /// Успешная регистрация: переход на Landing.
  void _onSuccess() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(RouteNames.landing, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(title: 'Регистрация'),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) => SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Создать аккаунт', style: AppTypography.h1),
                      const SizedBox(height: 8),
                      Text(
                        'Регистрация по email и паролю',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      AppTextField(
                        controller: _vm.nameController,
                        label: 'Имя',
                        hint: 'Как вас называть',
                        errorText: _vm.nameError,
                        enabled: !_vm.busy,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                        ),
                        onChanged: _vm.onNameChanged,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: _vm.emailController,
                        label: 'Email',
                        hint: 'name@domain.ru',
                        errorText: _vm.emailError,
                        enabled: !_vm.busy,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(
                          Icons.alternate_email_rounded,
                          size: 20,
                        ),
                        onChanged: _vm.onEmailChanged,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: _vm.passwordController,
                        label: 'Пароль',
                        hint: 'Минимум 6 символов',
                        errorText: _vm.passwordError,
                        enabled: !_vm.busy,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Чекбокс согласия с документами (ссылки кликабельны).
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppCheckbox(
                            value: _agreed,
                            onChanged: (value) {
                              AppLogger.debug(
                                'Registration',
                                'Чекбокс',
                                'согласие: $value',
                              );
                              setState(() => _agreed = value);
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              children: [
                                Text(
                                  'Я принимаю ',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                _docLink(
                                  'Пользовательское соглашение',
                                  RouteNames.userAgreement,
                                ),
                                Text(
                                  ' и ',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                _docLink(
                                  'Политику конфиденциальности',
                                  RouteNames.privacyPolicy,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Фиксированная нижняя кнопка (требование макета).
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: AppButton(
                  label: 'Создать аккаунт',
                  loading: _vm.busy,
                  onPressed: (!_agreed || _vm.busy)
                      ? null
                      : () => _vm.submit(onSuccess: (_) => _onSuccess()),
                ),
              ),
              TextButton(
                onPressed: () {
                  AppLogger.info('Registration', 'Нажатие кнопки', '«Войти»');
                  Navigator.of(context).pushReplacementNamed(RouteNames.login);
                },
                child: Text(
                  'Уже есть аккаунт? Войти',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ссылка на документ соглашения/политики.
  Widget _docLink(String label, String route) => InkWell(
    onTap: () => Navigator.of(context).pushNamed(route),
    child: Text(
      label,
      style: AppTypography.caption.copyWith(
        color: AppColors.secondary,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.secondary,
      ),
    ),
  );
}
