import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:travel_dairy/screens/login_screen.dart';
import 'package:travel_dairy/providers/locale_provider.dart';
import 'package:travel_dairy/providers/trips_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mocktail/mocktail.dart';

class MockLocaleProvider extends Mock implements LocaleProvider {}
class MockTripsProvider extends Mock implements TripsProvider {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  late MockLocaleProvider mockLocaleProvider;
  late MockTripsProvider mockTripsProvider;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseAnalytics mockAnalytics;

  setUp(() {
    mockLocaleProvider = MockLocaleProvider();
    mockTripsProvider = MockTripsProvider();
    mockAuth = MockFirebaseAuth();
    mockAnalytics = MockFirebaseAnalytics();

    // Mock locale to return Ukrainian by default
    when(() => mockLocaleProvider.locale).thenReturn(const Locale('uk', 'UA'));
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(value: mockLocaleProvider),
        ChangeNotifierProvider<TripsProvider>.value(value: mockTripsProvider),
      ],
      child: MaterialApp(
        home: LoginScreen(
          auth: mockAuth,
          analytics: mockAnalytics,
        ),
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen renders all input fields and buttons', (WidgetTester tester) async {
      // Note: We might need to handle Firebase initialization error if LoginScreen calls it on init
      // But typically it only calls it on action.
      
      await tester.pumpWidget(createWidgetUnderTest());

      // Check for AppStrings values (Ukrainian because of our mock)
      expect(find.text('Електронна пошта'), findsOneWidget);
      expect(find.text('Пароль'), findsOneWidget);
      expect(find.text('Увійти'), findsAtLeast(1)); 
      
      // Check for text fields
      expect(find.byType(TextFormField), findsNWidgets(2));
      
      // Check for buttons
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('validation errors appear when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap the login button without entering anything
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Check for validation messages
      expect(find.text('Будь ласка, введіть електронну пошту'), findsOneWidget);
      expect(find.text('Будь ласка, введіть пароль'), findsOneWidget);
    });
  });
}
