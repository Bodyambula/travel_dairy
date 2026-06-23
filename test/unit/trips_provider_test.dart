import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_dairy/providers/trips_provider.dart';
import 'package:travel_dairy/repositories/trips_repository.dart';
import 'dart:async';

class MockTripsRepository extends Mock implements TripsRepository {}

class FakeTrip extends Fake implements Trip {}

void main() {
  late TripsProvider tripsProvider;
  late MockTripsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeTrip());
  });

  setUp(() {
    mockRepository = MockTripsRepository();
    tripsProvider = TripsProvider(repository: mockRepository);
  });

  group('TripsProvider Tests', () {
    test('initial state is correct', () {
      expect(tripsProvider.trips, isEmpty);
      expect(tripsProvider.isLoading, isFalse);
      expect(tripsProvider.errorMessage, isNull);
    });

    test('fetchTrips sets loading state and updates trips on success', () async {
      final mockTrips = [
        Trip(
          id: '1',
          userId: 'user1',
          title: 'Trip 1',
          cities: ['City 1'],
          dates: ['2026-01-01'],
          photosCount: 0,
        ),
      ];

      final controller = StreamController<List<Trip>>();
      when(() => mockRepository.getTripsStream(any()))
          .thenAnswer((_) => controller.stream);

      tripsProvider.fetchTrips('user1');

      expect(tripsProvider.isLoading, isTrue);
      
      controller.add(mockTrips);
      
      // Wait for the stream listener to finish
      await Future.delayed(Duration.zero);

      expect(tripsProvider.isLoading, isFalse);
      expect(tripsProvider.trips.length, 1);
      expect(tripsProvider.trips[0].title, 'Trip 1');
      
      controller.close();
    });

    test('fetchTrips sets error message on stream error', () async {
      final controller = StreamController<List<Trip>>();
      when(() => mockRepository.getTripsStream(any()))
          .thenAnswer((_) => controller.stream);

      tripsProvider.fetchTrips('user1');

      controller.addError('Something went wrong');
      
      await Future.delayed(Duration.zero);

      expect(tripsProvider.isLoading, isFalse);
      expect(tripsProvider.errorMessage, contains('Something went wrong'));
      
      controller.close();
    });

    test('addTrip calls repository addTrip', () async {
      final trip = Trip(userId: 'u1', title: 'T1', cities: [], dates: [], photosCount: 0);
      when(() => mockRepository.addTrip(any())).thenAnswer((_) async {});

      await tripsProvider.addTrip(trip);

      verify(() => mockRepository.addTrip(trip)).called(1);
    });

    test('updateTrip calls repository updateTrip', () async {
      final trip = Trip(id: 'id1', userId: 'u1', title: 'T1', cities: [], dates: [], photosCount: 0);
      when(() => mockRepository.updateTrip(any())).thenAnswer((_) async {});

      await tripsProvider.updateTrip(trip);

      verify(() => mockRepository.updateTrip(trip)).called(1);
    });

    test('deleteTrip calls repository deleteTrip', () async {
      final tripId = 'id123';
      when(() => mockRepository.deleteTrip(any())).thenAnswer((_) async {});

      await tripsProvider.deleteTrip(tripId);

      verify(() => mockRepository.deleteTrip(tripId)).called(1);
    });

    test('fetchTrips handles multiple stream updates', () async {
      final controller = StreamController<List<Trip>>();
      when(() => mockRepository.getTripsStream(any())).thenAnswer((_) => controller.stream);

      tripsProvider.fetchTrips('user_multi');

      controller.add([Trip(userId: 'u1', title: 'T1', cities: [], dates: [], photosCount: 0)]);
      await Future.delayed(Duration.zero);
      expect(tripsProvider.trips.length, 1);

      controller.add([
        Trip(userId: 'u1', title: 'T1', cities: [], dates: [], photosCount: 0),
        Trip(userId: 'u1', title: 'T2', cities: [], dates: [], photosCount: 0)
      ]);
      await Future.delayed(Duration.zero);
      expect(tripsProvider.trips.length, 2);

      controller.close();
    });

    test('addTrip rethrows repository error', () async {
      final trip = Trip(userId: 'u1', title: 'T1', cities: [], dates: [], photosCount: 0);
      when(() => mockRepository.addTrip(any())).thenThrow(Exception('Write failed'));

      expect(() => tripsProvider.addTrip(trip), throwsA(isA<Exception>()));
    });

    test('updateTrip rethrows repository error', () async {
      final trip = Trip(id: '1', userId: 'u1', title: 'T1', cities: [], dates: [], photosCount: 0);
      when(() => mockRepository.updateTrip(any())).thenThrow(Exception('Update failed'));

      expect(() => tripsProvider.updateTrip(trip), throwsA(isA<Exception>()));
    });
  });
}
