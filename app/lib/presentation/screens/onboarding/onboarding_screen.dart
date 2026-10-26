import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../../common/logging/app_logger.dart';
import '../../navigation/route_names.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import '../widgets/screen_lifecycle.dart';

/// Описание одной страницы приветствия (иконка, заголовок, текст).
class _Slide {
  /// Иконка страницы.
  final IconData icon;

  /// Заголовок.
  final String title;

  /// Текст-описание.
  final String text;

  /// Создаёт описание страницы.
  const _Slide(this.icon, this.title, this.text);
}

/// Три экрана приветствия (только при первом запуске, есть пропуск).
///
/// Ответственность (SRP): показ обучающих страниц и фиксация факта показа.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class OnboardingScreen extends StatefulWidget {
  /// Создаёт экран приветствия.
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// Состояние приветствия: страницы, индикатор, кнопки «Пропустить/Далее».
class _OnboardingScreenState extends State<OnboardingScreen>
    with ScreenLifecycle<OnboardingScreen> {
  @override
  String get screenName => 'Onboarding';

  /// Контроллер пролистывания страниц.
  final PageController _pageController = PageController();

  /// ViewModel индекса страниц.
  late final OnboardingViewModel _vm = OnboardingViewModel();

  /// Контент страниц приветствия.
  static const List<_Slide> _slides = [
    _Slide(
      Icons.waving_hand_rounded,
      'Добро пожаловать!',
      'Приложение для соревнований в двух головоломках: '
          '«Картинка» и «Круг». Проверьте реакцию и внимательность.',
    ),
    _Slide(
      Icons.emoji_events_rounded,
      'Играй и зарабатывай',
      'Победы приносят очки недели. Следите за статистикой: '
          'сыгранные игры, награды и созданные турниры.',
    ),
    _Slide(
      Icons.groups_rounded,
      'Соревнуйся с другими',
      'Создавайте игры, приглашайте соперников и играйте '
          'одновременно — каждый собирает одну и ту же головоломку.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _vm.dispose();
    super.dispose();
  }

  /// Завершает приветствие: фиксирует факт показа и уходит на вход.
  Future<void> _finish({required bool skipped}) async {
    AppLogger.info(
      'Onboarding',
      'Нажатие кнопки',
      skipped ? '«Пропустить»' : '«Начать»',
    );
    await AppScope.of(context).prefsStore.markOnboardingShown();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Кнопка пропуска (всегда доступна — приветствие необязательно).
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _finish(skipped: true),
                child: Text(
                  'Пропустить',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: _vm.goTo,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 76,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide.title,
                          style: AppTypography.h1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.text,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Индикатор страниц.
            ListenableBuilder(
              listenable: _vm,
              builder: (context, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(OnboardingViewModel.pageCount, (i) {
                  final active = i == _vm.page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: ListenableBuilder(
                listenable: _vm,
                builder: (context, _) => AppButton(
                  label: _vm.isLastPage ? 'Начать' : 'Далее',
                  onPressed: () {
                    if (_vm.isLastPage) {
                      _finish(skipped: false);
                      return;
                    }
                    AppLogger.debug(
                      'Onboarding',
                      'Пролистывание',
                      'страница ${_vm.page + 1}',
                    );
                    _vm.nextPage();
                    _pageController.animateToPage(
                      _vm.page,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
