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

/// Экран входа в аккаунт (Login).
///
/// Ответственность (SRP): форма входа и переход после успешной авторизации.
/// Данные входа предзаполняются из локального хранилища (модуль Г).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class LoginScreen extends StatefulWidget {
  /// Создаёт экран входа.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Состояние экрана входа: ViewModel формы и построение UI.
class _LoginScreenState extends State<LoginScreen>
    with ScreenLifecycle<LoginScreen> {
  @override
  String get screenName => 'Login';

  /// ViewModel формы входа.
  late final AuthViewModel _vm;

  /// Зависимости созданы.
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    final services = AppScope.of(context);
    _vm = AuthViewModel(
      mode: AuthMode.login,
      signIn: SignInUseCase(services.authRepository),
      signUp: SignUpUseCase(services.authRepository),
    );

    // Предзаполнение сохранёнными данными входа.
    final saved = services.prefsStore.savedCredentials;
    if (saved.email.isNotEmpty) {
      _vm.emailController.text = saved.email;
      _vm.passwordController.text = saved.password;
      AppLogger.debug('LoginScreen', 'Предзаполнение формы', saved.email);
    }
  }

  @override
  void dispose() {
    if (_inited) _vm.dispose();
    super.dispose();
  }

  /// Успешный вход: сохранение данных формы и переход на Landing.
  Future<void> _onSuccess() async {
    final services = AppScope.of(context);
    await services.prefsStore.saveCredentials(
      email: _vm.emailController.text.trim(),
      password: _vm.passwordController.text,
    );
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(RouteNames.landing, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(title: 'Вход', showBack: false),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('С возвращением!', style: AppTypography.h1),
                const SizedBox(height: 8),
                Text(
                  'Войдите, чтобы продолжить соревнования',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
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
                  hint: 'Введите пароль',
                  errorText: _vm.passwordError,
                  enabled: !_vm.busy,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  onSubmitted: (_) => _vm.submit(
                    onSuccess: (_) {
                      _onSuccess();
                    },
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Войти',
                  loading: _vm.busy,
                  onPressed: _vm.busy
                      ? null
                      : () => _vm.submit(
                          onSuccess: (_) {
                            _onSuccess();
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      AppLogger.info(
                        'Login',
                        'Нажатие кнопки',
                        '«Регистрация»',
                      );
                      Navigator.of(context)
                          .pushReplacementNamed(RouteNames.register);
                    },
                    child: Text(
                      'Нет аккаунта? Зарегистрироваться',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Wrap(
                    spacing: 4,
                    children: [
                      _docLink(
                        'Политика конфиденциальности',
                        RouteNames.privacyPolicy,
                      ),
                      Text('•', style: AppTypography.caption),
                      _docLink('Соглашение', RouteNames.userAgreement),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Ссылка на документ (политика/соглашение).
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
