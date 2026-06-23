import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:travel_dairy/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Tests', () {
    testWidgets('App starts and shows login screen', (tester) async {
      // Start the app
      // Note: This will attempt to initialize Firebase. 
      // In a real CI environment, you'd use Firebase Emulator or a test project.
      app.main();
      await tester.pumpAndSettle();

      // Verify we are on the AuthWrapper which should show LoginScreen for unauthenticated users
      // Or show a loading indicator first
      expect(find.byType(CircularProgressIndicator), findsNothing);
      
      // Check for a known element on the login screen
      expect(find.text('Вітаємо знову!'), findsOneWidget);
    });

    testWidgets('Navigation to registration screen works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find and tap the "Register" link
      final registerLink = find.text('Зареєструватися');
      expect(registerLink, findsOneWidget);
      
      await tester.tap(registerLink.last); // Use .last if there are multiple (button + link)
      await tester.pumpAndSettle();

      // Verify we are on the registration screen
      expect(find.text('Створити акаунт'), findsOneWidget);
    });
  });
}
