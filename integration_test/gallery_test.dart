import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:travel_dairy/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Gallery and Photos Integration Tests', () {
    testWidgets('View Photos and Filter by Category', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Photos
      final photosTab = find.byIcon(Icons.photo_library).first;
      if (photosTab.evaluate().isEmpty) {
        print('Photos tab not found');
        return;
      }
      
      await tester.tap(photosTab);
      await tester.pumpAndSettle();

      expect(find.text('Галерея'), findsOneWidget);

      // Check for filters (ChoiceChips)
      expect(find.byType(ChoiceChip), findsAtLeast(1));
      
      // Tap a category if available (other than "All")
      final categoryChips = find.byType(ChoiceChip);
      if (categoryChips.evaluate().length > 1) {
        await tester.tap(categoryChips.at(1));
        await tester.pumpAndSettle();
        
        // Label should be selected
        final chip = tester.widget<ChoiceChip>(categoryChips.at(1));
        expect(chip.selected, isTrue);
      }
    });

    testWidgets('Open Full Screen Photo', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final photosTab = find.byIcon(Icons.photo_library).first;
      if (photosTab.evaluate().isEmpty) return;
      
      await tester.tap(photosTab);
      await tester.pumpAndSettle();

      // Check if there are any photos
      final photoGrid = find.byType(GestureDetector);
      // We look for grid items. They might not be there if no trips.
      if (photoGrid.evaluate().isNotEmpty) {
        await tester.tap(photoGrid.first);
        await tester.pumpAndSettle();
        
        // Should show a full screen view with a close button
        expect(find.byIcon(Icons.close), findsOneWidget);
        
        // Close it
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
        
        expect(find.byIcon(Icons.close), findsNothing);
      }
    });
  });
}
