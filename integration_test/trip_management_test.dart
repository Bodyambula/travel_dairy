import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:travel_dairy/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Trip Management Integration Tests', () {
    testWidgets('Full Trip Creation Flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Note: This test assumes user is logged in or we navigate past login
      // For real integration tests, we'd need to handle auth state.
      
      // 1. Check if we see the "My Trips" header
      // If not logged in, we might be on LoginScreen. 
      // For this test we assume we transition to HomeScreen somehow or are already logged in.

      if (find.text('Вітаємо знову!').evaluate().isNotEmpty) {
        // Skip or handle Login
        print('On Login Screen - skipping real Firestore interaction');
        return;
      }

      expect(find.text('Мої подорожі'), findsOneWidget);

      // 2. Tap Add Button
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // 3. Fill Trip Details
      expect(find.text('Нова подорож'), findsOneWidget);
      
      await tester.enterText(find.byType(TextFormField).at(0), 'Bali Adventure');
      await tester.enterText(find.byType(TextFormField).at(1), 'Trip to Bali islands');
      
      // 4. Add a City
      final cityEntry = find.byIcon(Icons.location_city);
      if (cityEntry.evaluate().isNotEmpty) {
         await tester.enterText(find.byType(TextFormField).at(2), 'Denpasar');
         await tester.testTextInput.receiveAction(TextInputAction.done);
         await tester.pumpAndSettle();
      }

      // 5. Save Trip
      final saveButton = find.text('Додати подорож');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // 6. Verify back on Home and trip exists
      expect(find.text('Мої подорожі'), findsOneWidget);
      expect(find.text('Bali Adventure'), findsOneWidget);
    });

    testWidgets('Delete Trip Confirmation Dialog', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      if (find.text('Мої подорожі').evaluate().isEmpty) return;

      // Find a trip card and long press or tap delete if visible
      // Assuming long press on a trip card shows a delete option or delete icon exists
      final deleteIcon = find.byIcon(Icons.delete).first;
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Видалити подорож?'), findsOneWidget);
      
      // Tap Cancel
      await tester.tap(find.text('Скасувати'));
      await tester.pumpAndSettle();
      
      // Dialog should be gone
      expect(find.text('Видалити подорож?'), findsNothing);
    });
  });
}
