import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

/// Аватар игрока: сетевая картинка (с дисковым кэшем), локальный файл
/// (фото с камеры/галереи) или плейсхолдер с иконкой.
///
/// Ответственность (SRP): отображение фото профиля в любых источниках.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class AppAvatar extends StatelessWidget {
  /// Путь к фото (URL, локальный путь или null/пусто).
  final String? photoUrl;

  /// Диаметр аватара.
  final double size;

  /// Создаёт аватар.
  ///
  /// [photoUrl] — фото; [size] — диаметр.
  const AppAvatar({super.key, this.photoUrl, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final url = photoUrl ?? '';
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: AppColors.surfaceAlt,
        child: _image(url),
      ),
    );
  }

  /// Выбирает отрисовку по типу источника [url].
  ///
  /// [url] — путь/ссылка; возвращает виджет изображения или плейсхолдер.
  Widget _image(String url) {
    if (url.isEmpty) return _placeholder();
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => _placeholder(),
        errorWidget: (_, _, _) => _placeholder(),
      );
    }
    final file = File(url);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return _placeholder();
        },
      );
    }
    return _placeholder();
  }

  /// Заглушка с иконкой профиля.
  Widget _placeholder() => Icon(
    Icons.person_rounded,
    size: size * 0.5,
    color: AppColors.textSecondary,
  );
}
