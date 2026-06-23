import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:travel_dairy/screens/settings_screen.dart';
import 'package:travel_dairy/providers/trips_provider.dart';
import 'package:travel_dairy/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockTripsProvider extends Mock implements TripsProvider {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockTripsProvider mockTripsProvider;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockTripsProvider = MockTripsProvider();
    
    when(() => mockTripsProvider.trips).thenReturn([]);
    
    SharedPreferences.setMockInitialValues({
      'push_notifications': true,
      'sync_enabled': true,
      'language_code': 'uk',
    });
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<TripsProvider>.value(value: mockTripsProvider),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            locale: localeProvider.locale,
            home: SettingsScreen(auth: mockAuth),
            routes: {
              '/login': (context) => const Scaffold(body: Text('Login Screen')),
            },
          );
        },
      ),
    );
  }

  group('SettingsScreen Widget Tests', () {
    testWidgets('renders all settings options', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Налаштування'), findsOneWidget);
      expect(find.text('Push-нагадування'), findsOneWidget);
      expect(find.text('Синхронізація'), findsOneWidget);
      expect(find.text('Мова інтерфейсу'), findsOneWidget);
    });

    testWidgets('toggling switch updates UI', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final pushSwitch = find.byType(Switch).first;
      expect(tester.widget<Switch>(pushSwitch).value, isTrue);

      await tester.tap(pushSwitch);
      await tester.pump();

      expect(tester.widget<Switch>(pushSwitch).value, isFalse);
    });

    testWidgets('logout button triggers signOut and navigation', (tester) async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final logoutBtn = find.text('Вийти з акаунту');
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      verify(() => mockAuth.signOut()).called(1);
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('language switch opens bottom sheet', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the specific tile for language
      await tester.tap(find.text('Мова інтерфейсу'));
      await tester.pumpAndSettle();

      // Check for presence of English and Ukrainian text in the bottom sheet
      expect(find.textContaining('English'), findsOneWidget);
      expect(find.textContaining('Українська'), findsAtLeast(1));
    });
  });
}
