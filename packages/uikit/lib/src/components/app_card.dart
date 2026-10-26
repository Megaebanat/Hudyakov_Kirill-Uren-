import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Универсальная карточка UIKit.
///
/// Два режима: с произвольным [child] (композиция) либо с готовым содержимым
/// через title/subtitle/imageUrl/trailing. Соотношение сторон превью
/// фиксируется параметром [imageAspectRatio] и не искажается.
///
/// Ответственность (SRP): отображение карточки и трансляция нажатия.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppCard extends StatelessWidget {
  /// Заголовок карточки (для режима title/subtitle).
  final String? title;

  /// Подзаголовок (для режима title/subtitle).
  final String? subtitle;

  /// URL изображения-превью (загружается с кэшированием вызывающей стороной).
  final String? imageUrl;

  /// Ведущая иконка, если нет изображения.
  final IconData? leadingIcon;

  /// Правый элемент (кнопка/бейдж).
  final Widget? trailing;

  /// Произвольное содержимое вместо title/subtitle.
  final Widget? child;

  /// Обработчик нажатия; null — карточка некликабельна.
  final VoidCallback? onTap;

  /// Отступ содержимого.
  final EdgeInsetsGeometry padding;

  /// Фиксированное соотношение сторон превью (защита от искажений).
  final double imageAspectRatio;

  /// Создаёт карточку.
  ///
  /// [title] — заголовок; [subtitle] — подзаголовок; [imageUrl] — картинка;
  /// [leadingIcon] — иконка; [trailing] — правый элемент; [child] — контент;
  /// [onTap] — нажатие; [padding] — отступы; [imageAspectRatio] — пропорции.
  const AppCard({
    super.key,
    this.title,
    this.subtitle,
    this.imageUrl,
    this.leadingIcon,
    this.trailing,
    this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.imageAspectRatio = 1,
  });

  @override
  Widget build(BuildContext context) {
    final content = child != null
        ? child!
        : Row(
            children: [
              _leading(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppTypography.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          );

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        highlightColor: AppColors.pressedOverlay,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outline),
          ),
          child: content,
        ),
      ),
    );
  }

  /// Собирает левый элемент: превью-картинка (с дисковым кэшем) либо иконка.
  ///
  /// Без параметров; размер фиксирован (не искажается при загрузке).
  Widget _leading() {
    const size = 56.0;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size * imageAspectRatio,
          fit: BoxFit.cover,
          placeholder: (_, __) => _placeholder(size),
          errorWidget: (_, __, ___) => _placeholder(size),
        ),
      );
    }
    return _placeholder(size);
  }

  /// Плейсхолдер изображения (иконка на фоне surfaceAlt).
  ///
  /// [size] — квадратный размер; возвращает виджет-заглушку.
  Widget _placeholder(double size) => Container(
        width: size,
        height: size * imageAspectRatio,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          leadingIcon ?? Icons.sports_esports_outlined,
          color: AppColors.textSecondary,
        ),
      );
}
