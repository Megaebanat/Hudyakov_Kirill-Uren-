import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../common/utils/formatters.dart';
import '../../domain/entities/game.dart';

/// Модель карточки игры для списков (presentation-модель).
///
/// Ответственность (SRP): готовые к отображению данные карточки.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GameCardData {
  /// Идентификатор игры.
  final String id;

  /// Заголовок карточки.
  final String title;

  /// Подзаголовок (дата/время, участник).
  final String subtitle;

  /// Иконка категории (image/circle).
  final IconData icon;

  /// Цвет иконки/акцента категории.
  final Color accent;

  /// Бейдж статуса (например, «Ожидает»).
  final String badge;

  /// Цвет бейджа.
  final Color badgeColor;

  /// Создаёт модель карточки.
  const GameCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.badge,
    required this.badgeColor,
  });
}

/// Маппер доменной сущности Game → presentation-модель [GameCardData].
///
/// Ответственность (SRP): преобразование игры в данные карточки списка
/// (единое место форматирования дат и статусов — DRY для всех экранов).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract final class GameCardMapper {
  /// Преобразует [game] в карточку списка.
  ///
  /// [game] — доменная игра; возвращает готовую к отрисовке модель.
  static GameCardData map(Game game) {
    final isCircle = game.category == GameCategory.circle;
    final subtitle = Formatters.gameDateTime(game.scheduledAt);

    return GameCardData(
      id: game.id,
      title: game.title,
      subtitle: subtitle,
      icon: isCircle ? Icons.circle_outlined : Icons.image_outlined,
      accent: isCircle ? AppColors.secondary : AppColors.accentRed,
      badge: _badgeFor(game),
      badgeColor: _badgeColorFor(game),
    );
  }

  /// Текст бейджа по статусу/составу игры.
  static String _badgeFor(Game game) => switch (game.status) {
    GameStatus.waiting => 'Ожидает',
    GameStatus.upcoming => 'Назначена',
    GameStatus.inProgress => 'Идёт',
    GameStatus.finished => 'Завершена',
  };

  /// Цвет бейджа по статусу игры.
  static Color _badgeColorFor(Game game) => switch (game.status) {
    GameStatus.waiting => AppColors.warning,
    GameStatus.upcoming => AppColors.secondary,
    GameStatus.inProgress => AppColors.primary,
    GameStatus.finished => AppColors.textSecondary,
  };
}
