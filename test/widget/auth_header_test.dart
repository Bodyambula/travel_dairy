import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_dairy/widgets/AuthWidget.dart';

void main() {
  group('AuthHeader Widget Tests', () {
    testWidgets('AuthHeader renders title and subtitle correctly', (WidgetTester tester) async {
      const title = 'Welcome';
      const subtitle = 'Please sign in to continue';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthHeader(
              title: title,
              subtitle: subtitle,
            ),
          ),
        ),
      );

      // Verify that the title is displayed
      expect(find.text(title), findsOneWidget);
      
      // Verify that the subtitle is displayed
      expect(find.text(subtitle), findsOneWidget);
      
      // Verify styling (optional but good)
      final titleWidget = tester.widget<Text>(find.text(title));
      expect(titleWidget.style?.color, Colors.white);
      expect(titleWidget.style?.fontSize, 32);
    });
  });
}
