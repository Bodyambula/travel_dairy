import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:travel_dairy/screens/registration_screen.dart';
import 'package:travel_dairy/providers/trips_provider.dart';
import 'package:travel_dairy/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockTripsProvider extends Mock implements TripsProvider {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseAnalytics mockAnalytics;
  late MockTripsProvider mockTripsProvider;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockAnalytics = MockFirebaseAnalytics();
    mockTripsProvider = MockTripsProvider();
    
    when(() => mockTripsProvider.trips).thenReturn([]);
    
    SharedPreferences.setMockInitialValues({});
    
    // Increase surface size for tests to avoid off-screen issues
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.implicitView!.physicalSize = const Size(800, 1200);
    binding.platformDispatcher.implicitView!.devicePixelRatio = 1.0;
  });

  Widget createWidgetUnderTest() {
    final localeProvider = LocaleProvider();
    // No need to setLocale as default is 'uk'
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider<TripsProvider>.value(value: mockTripsProvider),
      ],
      child: MaterialApp(
        locale: const Locale('uk', 'UA'),
        home: RegistrationScreen(
          auth: mockAuth,
          analytics: mockAnalytics,
        ),
      ),
    );
  }

  group('Registration Validation Granular Tests', () {
    testWidgets('error message for empty name', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      final button = find.byType(ElevatedButton);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      
      expect(find.text("Будь ласка, введіть ваше ім'я"), findsOneWidget);
    });

    testWidgets('error message for short name', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(0), 'A');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text("Ім'я має містити щонайменше 2 символи"), findsOneWidget);
    });

    testWidgets('error message for name with numbers', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(0), 'John123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text("Ім'я не може містити цифри"), findsOneWidget);
    });

    testWidgets('error message for invalid email', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Введіть коректну електронну адресу'), findsOneWidget);
    });

    testWidgets('error message for weak password (too short)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(2), 'short');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Пароль має містити не менше 6 символів'), findsOneWidget);
    });

    testWidgets('error message for password without digits', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(2), 'PasswordOnlyLetters');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Пароль має містити хоча б одну цифру'), findsOneWidget);
    });

    testWidgets('error message for password without letters', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(2), '12345678');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      expect(find.text('Пароль має містити хоча б одну літеру'), findsOneWidget);
    });
  });
}
