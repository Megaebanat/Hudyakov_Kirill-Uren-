/// Публичный API библиотеки UIKit.
///
/// Библиотека спроектирована как независимый модуль со своей версией (semver):
/// компоненты не содержат бизнес-логики (SRP), открыты для расширения через
/// параметры и закрыты для модификации (OCP), зависимости направлены на
/// абстракции Flutter, а цвета/типографика/тема имеют единственный источник
/// истины (DRY).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
library;

export 'src/components/app_bottom_bar.dart';
export 'src/components/app_button.dart';
export 'src/components/app_card.dart';
export 'src/components/app_checkbox.dart';
export 'src/components/app_pagination.dart';
export 'src/components/app_select.dart';
export 'src/components/app_text_field.dart';
export 'src/components/app_timer.dart';
export 'src/feedback/app_bottom_sheet.dart';
export 'src/feedback/app_error_banner.dart';
export 'src/theme/app_colors.dart';
export 'src/theme/app_theme.dart';
export 'src/theme/app_typography.dart';
