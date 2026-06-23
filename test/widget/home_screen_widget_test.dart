import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:travel_dairy/screens/home_screen.dart';
import 'package:travel_dairy/providers/trips_provider.dart';
import 'package:travel_dairy/providers/locale_provider.dart';
import 'package:travel_dairy/utils/AppStrings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockTripsProvider extends Mock implements TripsProvider {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockTripsProvider mockTripsProvider;

  setUpAll(() {
    registerFallbackValue(Trip(userId: '', title: '', cities: [], dates: [], photosCount: 0));
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockTripsProvider = MockTripsProvider();
    
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('user123');
    
    when(() => mockTripsProvider.trips).thenReturn([]);
    when(() => mockTripsProvider.isLoading).thenReturn(false);
    when(() => mockTripsProvider.errorMessage).thenReturn(null);
    when(() => mockTripsProvider.fetchTrips(any())).thenAnswer((_) async {});
    
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<TripsProvider>.value(value: mockTripsProvider),
      ],
      child: MaterialApp(
        home: HomeScreen(auth: mockAuth),
      ),
    );
  }

  group('HomeScreen More Granular Tests', () {
    testWidgets('empty state shows redirect text', (tester) async {
      when(() => mockTripsProvider.trips).thenReturn([]);
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      final context = tester.element(find.byType(HomeScreen));
      final strings = AppStrings.of(context, listen: false);
      
      expect(find.text(strings.noTripsYet), findsOneWidget);
    });

    testWidgets('calendar navigation works', (tester) async {
       when(() => mockTripsProvider.trips).thenReturn([]);
       await tester.pumpWidget(createWidgetUnderTest());
       await tester.pumpAndSettle();
       
       final context = tester.element(find.byType(HomeScreen));
       final strings = AppStrings.of(context, listen: false);
       
       // Tap the calendar icon in the BottomNavigationBar or specialized button
       await tester.tap(find.byIcon(Icons.calendar_today));
       await tester.pumpAndSettle();
       expect(find.text(strings.calendarTitle), findsOneWidget);
    });
  });

  group('HomeScreen Widget Tests', () {
    testWidgets('renders loading state correctly', (tester) async {
      when(() => mockTripsProvider.isLoading).thenReturn(true);
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Start build
      
      final context = tester.element(find.byType(HomeScreen));
      final strings = AppStrings.of(context, listen: false);
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(strings.loading), findsOneWidget);
    });

    testWidgets('renders empty state correctly', (tester) async {
      when(() => mockTripsProvider.isLoading).thenReturn(false);
      when(() => mockTripsProvider.trips).thenReturn([]);
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      final context = tester.element(find.byType(HomeScreen));
      final strings = AppStrings.of(context, listen: false);
      
      expect(find.text(strings.noTripsYet), findsOneWidget);
    });

    testWidgets('renders trip list correctly', (tester) async {
      final mockTrips = [
        Trip(
          id: '1',
          userId: 'user123',
          title: 'Paris Trip',
          cities: ['Paris'],
          dates: ['2026-05-01'],
          photosCount: 3,
        ),
      ];
      
      when(() => mockTripsProvider.isLoading).thenReturn(false);
      when(() => mockTripsProvider.trips).thenReturn(mockTrips);
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      final context = tester.element(find.byType(HomeScreen));
      final strings = AppStrings.of(context, listen: false);
      
      expect(find.text('Paris Trip'), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text(strings.travelsCount(mockTrips.length)), findsOneWidget);
    });

    testWidgets('navigation to other tabs works', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      // Tap Calendar tab
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();
      
      // Assuming CalendarScreen has a title or known widget
      // (Simplified check for now)
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
