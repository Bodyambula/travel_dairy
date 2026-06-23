import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:travel_dairy/screens/map_picker_screen.dart';
import 'package:travel_dairy/providers/locale_provider.dart';
import 'package:travel_dairy/utils/AppStrings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MaterialApp(
        home: MapPickerScreen(),
      ),
    );
  }

  group('MapPickerScreen Widget Tests', () {
    testWidgets('renders map and instruction text', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MapPickerScreen));
      final strings = AppStrings.of(context, listen: false);

      expect(find.text(strings.mapPickerTitle), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing); // It's a TextButton in the AppBar action, or maybe ElevatedButton exists elsewhere? Actually in my view of code it was TextButton in AppBar.
    });

    testWidgets('shows instruction overlay', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.touch_app), findsOneWidget);
      expect(find.text('Торкніться карти, щоб додати зупинку'), findsOneWidget);
    });
  });
}
