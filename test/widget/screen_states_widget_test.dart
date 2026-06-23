import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:travel_dairy/screens/home_screen.dart';
import 'package:travel_dairy/screens/photos_screen.dart';
import 'package:travel_dairy/providers/trips_provider.dart';
import 'package:travel_dairy/providers/locale_provider.dart';
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
    when(() => mockTripsProvider.fetchTrips(any())).thenAnswer((_) async {});
    
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestApp(Widget home) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<TripsProvider>.value(value: mockTripsProvider),
      ],
      child: MaterialApp(home: home),
    );
  }

  group('Screen State Consistency Tests', () {
    testWidgets('HomeScreen shows loading spinner', (tester) async {
      when(() => mockTripsProvider.isLoading).thenReturn(true);
      when(() => mockTripsProvider.trips).thenReturn([]);
      when(() => mockTripsProvider.errorMessage).thenReturn(null);

      await tester.pumpWidget(createTestApp(HomeScreen(auth: mockAuth)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('HomeScreen shows error message and retry button', (tester) async {
      when(() => mockTripsProvider.isLoading).thenReturn(false);
      when(() => mockTripsProvider.errorMessage).thenReturn('Network failure');
      when(() => mockTripsProvider.trips).thenReturn([]);

      await tester.pumpWidget(createTestApp(HomeScreen(auth: mockAuth)));
      await tester.pump();

      expect(find.text('Network failure'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('PhotosScreen shows empty state message', (tester) async {
      when(() => mockTripsProvider.trips).thenReturn([]);
      
      await tester.pumpWidget(createTestApp(const PhotosScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Немає фотографій'), findsOneWidget);
    });

    testWidgets('HomeScreen shows empty state message', (tester) async {
      when(() => mockTripsProvider.isLoading).thenReturn(false);
      when(() => mockTripsProvider.errorMessage).thenReturn(null);
      when(() => mockTripsProvider.trips).thenReturn([]);

      await tester.pumpWidget(createTestApp(HomeScreen(auth: mockAuth)));
      await tester.pumpAndSettle();

      expect(find.text('Поки що немає подорожей'), findsOneWidget);
    });
  });
}
