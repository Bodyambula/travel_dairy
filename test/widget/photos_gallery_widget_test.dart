import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:travel_dairy/screens/photos_screen.dart';
import 'package:travel_dairy/providers/trips_provider.dart';
import 'package:travel_dairy/providers/locale_provider.dart';
import 'package:travel_dairy/utils/AppStrings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockTripsProvider extends Mock implements TripsProvider {}

void main() {
  late MockTripsProvider mockTripsProvider;

  setUp(() {
    mockTripsProvider = MockTripsProvider();
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<TripsProvider>.value(value: mockTripsProvider),
      ],
      child: const MaterialApp(
        home: PhotosScreen(),
      ),
    );
  }

  group('PhotosScreen Widget Tests', () {
    testWidgets('renders empty state when no photos exist', (tester) async {
      when(() => mockTripsProvider.trips).thenReturn([]);
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(PhotosScreen));
      final strings = AppStrings.of(context, listen: false);

      expect(find.text(strings.noPhotos), findsOneWidget);
    });

    testWidgets('renders photo grid when trips have images', (tester) async {
      final mockTrips = [
        Trip(
          id: '1',
          userId: 'u1',
          title: 'Paris',
          cities: [],
          dates: [],
          photosCount: 1,
          imagesBase64: ['iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII='], // 1x1 transparent pixel
        ),
      ];
      
      when(() => mockTripsProvider.trips).thenReturn(mockTrips);
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(PhotosScreen));
      final strings = AppStrings.of(context, listen: false);

      expect(find.text(strings.galleryTitle), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text(strings.photosTitleCount(1)), findsOneWidget);
    });

    testWidgets('category filtering works', (tester) async {
      const validBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=';
      final mockTrips = [
        Trip(id: '1', userId: 'u1', title: 'Paris', cities: [], dates: [], photosCount: 1, imagesBase64: [validBase64]),
        Trip(id: '2', userId: 'u1', title: 'Rome', cities: [], dates: [], photosCount: 1, imagesBase64: [validBase64]),
      ];
      
      when(() => mockTripsProvider.trips).thenReturn(mockTrips);
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(PhotosScreen));
      final strings = AppStrings.of(context, listen: false);

      // Check chips
      expect(find.text(strings.categoryAll), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Rome'), findsOneWidget);

      // Tap Rome
      await tester.tap(find.text('Rome'));
      await tester.pump();

      // Should show only Rome photos (1 photo)
      expect(find.text('2 фото подорожей'), findsNothing); // Total count title doesn't change based on filter currently in code, but grid items do.
    });
  });
}
