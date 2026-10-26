import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

/// Общая обёртка демо-страницы: прокручиваемый список блоков.
///
/// Ответственность (SRP): единая вёрстка страниц витрины.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class DemoScaffold extends StatelessWidget {
  /// Заголовок страницы.
  final String title;

  /// Блоки демо-состояний.
  final List<Widget> children;

  /// Создаёт страницу демо.
  ///
  /// [title] — заголовок; [children] — блоки состояний.
  const DemoScaffold({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final child in children) ...[child, const SizedBox(height: 20)],
        ],
      ),
    );
  }
}

/// Подзаголовок блока состояний внутри DemoScaffold.
class DemoSection extends StatelessWidget {
  /// Текст подзаголовка.
  final String text;

  /// Создаёт подзаголовок.
  ///
  /// [text] — текст; [key] — ключ виджета.
  const DemoSection(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: AppTypography.label),
      );
}

/// Демо палитры [AppColors].
///
/// Ответственность (SRP): визуализация цветов дизайн-системы.
class ColorsDemoPage extends StatelessWidget {
  /// Создаёт страницу цветов.
  const ColorsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const colors = <MapEntry<String, Color>>[
      MapEntry('background', AppColors.background),
      MapEntry('surface', AppColors.surface),
      MapEntry('surfaceAlt', AppColors.surfaceAlt),
      MapEntry('outline', AppColors.outline),
      MapEntry('primary', AppColors.primary),
      MapEntry('secondary', AppColors.secondary),
      MapEntry('accentRed', AppColors.accentRed),
      MapEntry('success', AppColors.success),
      MapEntry('error', AppColors.error),
      MapEntry('warning', AppColors.warning),
      MapEntry('textPrimary', AppColors.textPrimary),
      MapEntry('textSecondary', AppColors.textSecondary),
      MapEntry('disabledFill', AppColors.disabledFill),
      MapEntry('disabledText', AppColors.disabledText),
    ];
    return DemoScaffold(
      title: 'Цвета',
      children: [
        const DemoSection('ПАЛИТРА DESIGN-СИСТЕМЫ'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final entry in colors)
              Container(
                width: 104,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: entry.value,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outline),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(entry.key, style: AppTypography.caption),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Демо типографики [AppTypography] (шрифт Inter).
///
/// Ответственность (SRP): визуализация текстовых стилей.
class TypographyDemoPage extends StatelessWidget {
  /// Создаёт страницу типографики.
  const TypographyDemoPage({super.key});

  @override
  Widget build(BuildContext context) => const DemoScaffold(
        title: 'Типографика',
        children: [
          DemoSection('DISPLAY — 32/38 BOLD'),
          Text('Создай игру', style: AppTypography.display),
          DemoSection('H1 — 28/38 BOLD'),
          Text('Регистрация', style: AppTypography.h1),
          DemoSection('H2 — 24/30 SEMIBOLD'),
          Text('Discover Combats', style: AppTypography.h2),
          DemoSection('H3 — 20/26 SEMIBOLD'),
          Text('Combat Information', style: AppTypography.h3),
          DemoSection('BODY — 16/24 MEDIUM'),
          Text(
            'Игра сохраняется на сервере после нажатия Publish.',
            style: AppTypography.body,
          ),
          DemoSection('BODY SMALL — 14/20 MEDIUM'),
          Text(
            'Выберите дату и время начала матча.',
            style: AppTypography.bodySmall,
          ),
          DemoSection('LABEL — 12/16 SEMIBOLD'),
          Text('THIS WEEK EARNINGS', style: AppTypography.label),
          DemoSection('CAPTION — 10/14 MEDIUM'),
          Text('Осталось 00:42', style: AppTypography.caption),
        ],
      );
}

/// Демо поля ввода: состояния enabled/error/disabled/пароль.
///
/// Ответственность (SRP): демонстрация состояний [AppTextField].
class TextFieldDemoPage extends StatefulWidget {
  /// Создаёт страницу поля ввода.
  const TextFieldDemoPage({super.key});

  @override
  State<TextFieldDemoPage> createState() => _TextFieldDemoPageState();
}

/// Состояние демо поля ввода: контроллеры для разных примеров.
class _TextFieldDemoPageState extends State<TextFieldDemoPage> {
  /// Контроллер примера с ошибкой.
  final TextEditingController _errorController =
      TextEditingController(text: 'user@mailcom');

  @override
  void dispose() {
    _errorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoScaffold(
        title: 'Поле ввода',
        children: [
          const DemoSection('ОБЫЧНОЕ (ENABLED)'),
          const AppTextField(
            label: 'EMAIL',
            hint: 'name@domain.ru',
            keyboardType: TextInputType.emailAddress,
          ),
          const DemoSection('С ОШИБКОЙ (ERROR)'),
          AppTextField(
            label: 'EMAIL',
            hint: 'name@domain.ru',
            controller: _errorController,
            errorText: 'Введите корректный email: name@domain.ru',
          ),
          const DemoSection('ПАРОЛЬ С КНОПКОЙ ПОКАЗА'),
          const AppTextField(
            label: 'PASSWORD',
            hint: 'Введите пароль',
            obscure: true,
          ),
          const DemoSection('ОТКЛЮЧЁННОЕ (DISABLED)'),
          const AppTextField(
            label: 'EMAIL',
            hint: 'Поле недоступно',
            enabled: false,
          ),
        ],
      );
}

/// Демо кнопок: варианты и состояния normal/disabled/loading.
///
/// Ответственность (SRP): демонстрация [AppButton].
class ButtonDemoPage extends StatelessWidget {
  /// Создаёт страницу кнопок.
  const ButtonDemoPage({super.key});

  @override
  Widget build(BuildContext context) => DemoScaffold(
        title: 'Кнопка',
        children: [
          const DemoSection('PRIMARY'),
          AppButton(label: 'Create Account', onPressed: () {}),
          const DemoSection('SECONDARY'),
          AppButton(
            label: 'Sign In',
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
          const DemoSection('GHOST'),
          AppButton(
            label: 'Пропустить',
            variant: AppButtonVariant.ghost,
            onPressed: () {},
            expand: false,
          ),
          const DemoSection('С ИКОНКОЙ'),
          AppButton(
            label: 'Опубликовать',
            icon: Icons.send_rounded,
            onPressed: () {},
          ),
          const DemoSection('DISABLED (onPressed == null)'),
          const AppButton(label: 'Create Account', onPressed: null),
          const DemoSection('LOADING'),
          AppButton(label: 'Create Account', onPressed: () {}, loading: true),
        ],
      );
}

/// Демо селекта с BottomSheet.
///
/// Ответственность (SRP): демонстрация [AppSelect].
class SelectDemoPage extends StatefulWidget {
  /// Создаёт страницу селекта.
  const SelectDemoPage({super.key});

  @override
  State<SelectDemoPage> createState() => _SelectDemoPageState();
}

/// Состояние демо селекта: выбранная категория игры.
class _SelectDemoPageState extends State<SelectDemoPage> {
  /// Выбранное значение категории.
  String? _category;

  @override
  Widget build(BuildContext context) => DemoScaffold(
        title: 'Селект',
        children: [
          const DemoSection('КАТЕГОРИЯ ИГРЫ (ОТКРЫВАЕТ BOTTOM SHEET)'),
          AppSelect<String>(
            label: 'CATEGORY',
            hint: 'Выберите категорию',
            value: _category,
            items: const [
              SelectItem(value: 'image', label: 'Image', icon: Icons.image_outlined),
              SelectItem(value: 'circle', label: 'Circle', icon: Icons.circle_outlined),
            ],
            onChanged: (value) => setState(() => _category = value),
          ),
          const SizedBox(height: 16),
          const DemoSection('НЕДОСТУПНЫЙ (DISABLED)'),
          const AppSelect<String>(
            label: 'CATEGORY',
            hint: 'Недоступно',
            value: null,
            items: [
              SelectItem(value: 'image', label: 'Image'),
              SelectItem(value: 'circle', label: 'Circle'),
            ],
            onChanged: _noop,
            enabled: false,
          ),
        ],
      );

  /// Пустой обработчик для disabled-примера.
  static void _noop(String value) {}
}

/// Демо пагинации (переключение страниц приветствия).
///
/// Ответственность (SRP): демонстрация [AppPagination].
class PaginationDemoPage extends StatefulWidget {
  /// Создаёт страницу пагинации.
  const PaginationDemoPage({super.key});

  @override
  State<PaginationDemoPage> createState() => _PaginationDemoPageState();
}

/// Состояние: текущая страница приветствия.
class _PaginationDemoPageState extends State<PaginationDemoPage> {
  /// Индекс активной страницы.
  int _page = 0;

  @override
  Widget build(BuildContext context) => DemoScaffold(
        title: 'Пагинация',
        children: [
          const DemoSection('ПРИВЕТСТВЕННЫЕ ЭКРАНЫ (3)'),
          Text('Страница ${_page + 1} из 3', style: AppTypography.body),
          const SizedBox(height: 12),
          AppPagination(
            pageCount: 3,
            currentIndex: _page,
            onSelect: (index) => setState(() => _page = index),
          ),
        ],
      );
}

/// Демо карточек.
///
/// Ответственность (SRP): демонстрация [AppCard].
class CardDemoPage extends StatelessWidget {
  /// Создаёт страницу карточек.
  const CardDemoPage({super.key});

  @override
  Widget build(BuildContext context) => DemoScaffold(
        title: 'Карточка',
        children: [
          const DemoSection('КАРТОЧКА ИГРЫ'),
          AppCard(
            title: 'Вечерний турнир',
            subtitle: 'Сегодня, 18:00 • Circle',
            leadingIcon: Icons.circle_outlined,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
            onTap: () {},
          ),
          const DemoSection('КАРТОЧКА ИГРОКА'),
          AppCard(
            title: 'Демо Игрок',
            subtitle: '240 очков',
            leadingIcon: Icons.person_outline_rounded,
            trailing: AppButton(
              label: 'Профиль',
              variant: AppButtonVariant.secondary,
              expand: false,
              height: 40,
              onPressed: () {},
            ),
          ),
          const DemoSection('С ПРОИЗВОЛЬНЫМ СОДЕРЖИМЫМ'),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Success!', style: AppTypography.h2),
                const SizedBox(height: 8),
                Text(
                  'Игра опубликована и сохранена на сервере.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

/// Демо нижнего меню с центральной кнопкой.
///
/// Ответственность (SRP): демонстрация [AppBottomBar].
class BottomBarDemoPage extends StatefulWidget {
  /// Создаёт страницу нижнего меню.
  const BottomBarDemoPage({super.key});

  @override
  State<BottomBarDemoPage> createState() => _BottomBarDemoPageState();
}

/// Состояние: активный пункт нижнего меню.
class _BottomBarDemoPageState extends State<BottomBarDemoPage> {
  /// Индекс активного пункта.
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Нижнее меню')),
        body: Center(
          child: Text(
            'Активен пункт: ${_index + 1}',
            style: AppTypography.body,
          ),
        ),
        bottomNavigationBar: AppBottomBar(
          items: const [
            AppBottomBarItem(
              icon: Icons.home_outlined,
              label: 'Landing',
            ),
            AppBottomBarItem(
              icon: Icons.military_tech_outlined,
              label: 'Combats',
            ),
            AppBottomBarItem(
              icon: Icons.bar_chart_rounded,
              label: 'Stats',
            ),
            AppBottomBarItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
            ),
          ],
          currentIndex: _index,
          onChanged: (index) => setState(() => _index = index),
          onCenterPressed: () {},
        ),
      );
}

/// Демо таймера обратного отсчёта.
///
/// Ответственность (SRP): демонстрация [AppTimer].
class TimerDemoPage extends StatelessWidget {
  /// Создаёт страницу таймера.
  const TimerDemoPage({super.key});

  @override
  Widget build(BuildContext context) => DemoScaffold(
        title: 'Таймер',
        children: [
          const DemoSection('КРУПНЫЙ РЕЖИМ (ИГРА)'),
          Center(
            child: AppTimer(
              duration: const Duration(minutes: 5),
              large: true,
              onFinished: () {},
            ),
          ),
          const DemoSection('КОМПАКТНЫЙ РЕЖИМ'),
          Center(child: AppTimer(duration: const Duration(seconds: 45))),
        ],
      );
}

/// Демо чекбокса: все состояния.
///
/// Ответственность (SRP): демонстрация [AppCheckbox].
class CheckboxDemoPage extends StatefulWidget {
  /// Создаёт страницу чекбокса.
  const CheckboxDemoPage({super.key});

  @override
  State<CheckboxDemoPage> createState() => _CheckboxDemoPageState();
}

/// Состояние: значение галки «уведомления».
class _CheckboxDemoPageState extends State<CheckboxDemoPage> {
  /// Включены ли уведомления об игре.
  bool _notifications = true;

  @override
  Widget build(BuildContext context) => DemoScaffold(
        title: 'Чекбокс',
        children: [
          const DemoSection('УВЕДОМЛЕНИЯ ЗА 1 ЧАС ДО ИГРЫ'),
          AppCheckbox(
            value: _notifications,
            label: 'Напомнить за час до начала игры',
            onChanged: (value) => setState(() => _notifications = value),
          ),
          const DemoSection('НЕДОСТУПНЫЙ'),
          const AppCheckbox(
            value: false,
            label: 'Недоступно (disabled)',
            enabled: false,
            onChanged: _noop,
          ),
        ],
      );

  /// Пустой обработчик для disabled-примера.
  static void _noop(bool value) {}
}

/// Демо уведомления об ошибке (5 секунд + кнопка закрытия).
///
/// Ответственность (SRP): демонстрация [AppErrorBanner].
class ErrorBannerDemoPage extends StatelessWidget {
  /// Создаёт страницу уведомлений.
  const ErrorBannerDemoPage({super.key});

  @override
  Widget build(BuildContext context) => DemoScaffold(
        title: 'Уведомление об ошибке',
        children: [
          const DemoSection('ОШИБКА СЕРВЕРА / НЕТ СОЕДИНЕНИЯ'),
          Text(
            'Уведомление показывается 5 секунд и закрывается кнопкой ✕.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Показать ошибку',
            icon: Icons.error_outline,
            variant: AppButtonVariant.secondary,
            onPressed: () => AppErrorBanner.show(
              context,
              'Ошибка загрузки данных с сервера (код 500)',
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Показать «нет интернета»',
            icon: Icons.wifi_off_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () => AppErrorBanner.show(
              context,
              'Нет соединения с сетью Интернет',
            ),
          ),
        ],
      );
}
