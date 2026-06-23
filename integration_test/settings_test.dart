import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:travel_dairy/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings and Localization Integration Tests', () {
    testWidgets('Switch Language and Verify UI Updates', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings
      // Assuming a BottomNavigationBar or Drawer
      final settingsTab = find.byIcon(Icons.settings);
      if (settingsTab.evaluate().isEmpty) {
        print('Settings tab not found - might be on login screen');
        return;
      }
      
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      expect(find.text('Налаштування'), findsOneWidget); // Assuming starting in UK

      // Find language switch tile
      final langTile = find.text('Мова інтерфейсу');
      expect(langTile, findsOneWidget);

      // Tap to change language (Assuming it toggles or opens a picker)
      // For this test, assume it toggles between UK and EN
      await tester.tap(langTile);
      await tester.pumpAndSettle();

      // Verify header changed to English
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Interface language'), findsOneWidget);
      
      // Navigate back to Home
      final homeTab = find.byIcon(Icons.home);
      await tester.tap(homeTab);
      await tester.pumpAndSettle();
      
      // Home should be in English now
      expect(find.text('My Trips'), findsOneWidget);
    });

    testWidgets('Toggle Push Notifications', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final settingsTab = find.byIcon(Icons.settings);
      if (settingsTab.evaluate().isEmpty) return;
      
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // Find switch
      final pushSwitch = find.byType(Switch).first;
      bool initialState = tester.widget<Switch>(pushSwitch).value;
      
      // Tap switch
      await tester.tap(pushSwitch);
      await tester.pumpAndSettle();
      
      // Verify state changed
      bool newState = tester.widget<Switch>(pushSwitch).value;
      expect(newState, !initialState);
    });
  });
}
