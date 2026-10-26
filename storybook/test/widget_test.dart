import 'package:flutter_test/flutter_test.dart';

import 'package:storybook/main.dart';

/// Дымовой тест StoryBook: приложение запускается и показывает каталог.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
void main() {
  testWidgets('StoryBook открывает каталог компонентов', (tester) async {
    await tester.pumpWidget(const StoryBookApp());
    expect(find.text('UIKit StoryBook'), findsOneWidget);
    expect(find.text('Цвета'), findsOneWidget);
    expect(find.text('Кнопка'), findsOneWidget);
  });
}
