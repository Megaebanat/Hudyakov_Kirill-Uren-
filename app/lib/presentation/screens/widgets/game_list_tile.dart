import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

import '../../mappers/game_card_mapper.dart';

/// Строка списка игр (Discover Combats / блоки Landing).
///
/// Ответственность (SRP): отрисовка одной карточки-строки игры.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class GameListTile extends StatelessWidget {
  /// Данные карточки (получены через [GameCardMapper]).
  final GameCardData data;

  /// Обработчик нажатия (переход к Combat Information).
  final VoidCallback? onTap;

  /// Создаёт строку списка.
  ///
  /// [data] — данные карточки; [onTap] — нажатие.
  const GameListTile({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: data.badgeColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              data.badge,
              style: AppTypography.caption.copyWith(
                color: data.badgeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
