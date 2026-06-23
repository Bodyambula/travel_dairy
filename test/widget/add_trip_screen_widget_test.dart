import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:travel_dairy/screens/add_trip_screen.dart';
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
    when(() => mockUser.uid).thenReturn('user-123');
    when(() => mockTripsProvider.fetchTrips(any())).thenAnswer((_) async {});
    when(() => mockTripsProvider.trips).thenReturn([]);
    when(() => mockTripsProvider.isLoading).thenReturn(false);
    when(() => mockTripsProvider.errorMessage).thenReturn(null);

    SharedPreferences.setMockInitialValues({});
    
    // Increase surface size for tests to avoid off-screen issues
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.implicitView!.physicalSize = const Size(800, 1500);
    binding.platformDispatcher.implicitView!.devicePixelRatio = 1.0;
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<TripsProvider>.value(value: mockTripsProvider),
      ],
      child: MaterialApp(
        home: AddTripScreen(auth: mockAuth),
      ),
    );
  }

  group('AddTripScreen Granular Logic Tests', () {
    testWidgets('title is required validation', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      final context = tester.element(find.byType(AddTripScreen));
      final strings = AppStrings.of(context, listen: false);
      
      final saveBtn = find.byIcon(Icons.check);
      await tester.tap(saveBtn);
      await tester.pump();
      
      expect(find.text(strings.errorEnterName), findsOneWidget);
    });

    testWidgets('adding city updates list', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).at(1), 'Rome');
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      
      expect(find.text('Rome'), findsOneWidget);
    });
  });

  group('AddTripScreen Widget Tests', () {
    testWidgets('renders all form fields correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(AddTripScreen));
      final strings = AppStrings.of(context, listen: false);

      expect(find.text(strings.newTripTitle), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeast(2)); // Title, Description, City
      expect(find.text(strings.tripNameLabel), findsOneWidget);
    });

    testWidgets('adding a city updates the UI list', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final cityField = find.byType(TextFormField).at(2);
      final addCityBtn = find.byIcon(Icons.add);

      await tester.enterText(cityField, 'London');
      await tester.tap(addCityBtn);
      await tester.pump();

      expect(find.text('London'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('removing a city updates the UI list', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final cityField = find.byType(TextFormField).at(2);
      final addCityBtn = find.byIcon(Icons.add);

      await tester.enterText(cityField, 'London');
      await tester.tap(addCityBtn);
      await tester.pump();
      
      expect(find.text('London'), findsOneWidget);

      final deleteIcon = find.byIcon(Icons.close).first;
      await tester.tap(deleteIcon);
      await tester.pump();

      expect(find.text('London'), findsNothing);
    });

    testWidgets('validation error when title is empty on save', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(AddTripScreen));
      final strings = AppStrings.of(context, listen: false);

      // The save icon is Icons.check. There's only one in the AppBar.
      final saveBtn = find.byIcon(Icons.check);
      await tester.tap(saveBtn);
      await tester.pump(); // Validation triggers on next frame

      expect(find.text(strings.errorEnterName), findsOneWidget);
    });
  });
}
