import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Поле ввода текста UIKit со всеми состояниями макета.
///
/// Поддерживаемые состояния: обычное (enabled), сфокусированное (focused),
/// с ошибкой (error), отключённое (disabled), с паролем (obscure + кнопка
/// «показать пароль»).
///
/// Ответственность (SRP): только отображение и ввод текста — валидация
/// выполняется вызывающей стороной и передаётся через [errorText].
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppTextField extends StatefulWidget {
  /// Контроллер текста (управление вызывающей стороной).
  final TextEditingController? controller;

  /// Лейбл над полем.
  final String? label;

  /// Подсказка, когда поле пустое.
  final String? hint;

  /// Текст ошибки; null — поле без ошибки.
  final String? errorText;

  /// Поле доступно для ввода (false — состояние disabled).
  final bool enabled;

  /// Скрывать ввод (поле пароля) с кнопкой показа.
  final bool obscure;

  /// Тип клавиатуры (email, phone и т.п.).
  final TextInputType? keyboardType;

  /// Действие клавиатуры (done, next...).
  final TextInputAction? textInputAction;

  /// Иконка слева (префикс).
  final Widget? prefixIcon;

  /// Иконка справа поверх кнопки показа пароля.
  final Widget? suffixIcon;

  /// Вызывается при изменении текста.
  final ValueChanged<String>? onChanged;

  /// Вызывается при завершении ввода (Enter/Done).
  final ValueChanged<String>? onSubmitted;

  /// Максимум строк (по умолчанию одна).
  final int maxLines;

  /// Создаёт поле ввода.
  ///
  /// [controller] — контроллер; [label] — лейбл; [hint] — подсказка;
  /// [errorText] — ошибка; [enabled] — доступность; [obscure] — пароль;
  /// [keyboardType] — клавиатура; [textInputAction] — действие клавиатуры;
  /// [prefixIcon] — иконка слева; [suffixIcon] — иконка справа;
  /// [onChanged] — изменение текста; [onSubmitted] — отправка;
  /// [maxLines] — количество строк.
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

/// Внутреннее состояние [AppTextField]: хранит видимость пароля.
///
/// Ответственность (SRP): локальное UI-состояние видимости текста.
class _AppTextFieldState extends State<AppTextField> {
  /// Пароль показан открытым текстом.
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final hidden = widget.obscure && !_visible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.label),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: hidden,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          maxLines: widget.maxLines,
          style: AppTypography.bodySmall.copyWith(
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.disabledText,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffix(),
          ),
        ),
      ],
    );
  }

  /// Собирает правую часть поля: кнопка показа пароля и/или [suffixIcon].
  ///
  /// Без параметров; возвращает null, если нечего отображать.
  Widget? _buildSuffix() {
    if (widget.obscure && widget.enabled) {
      return IconButton(
        tooltip: _visible ? 'Скрыть пароль' : 'Показать пароль',
        onPressed: () => setState(() => _visible = !_visible),
        icon: Icon(
          _visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
      );
    }
    return widget.suffixIcon;
  }
}
