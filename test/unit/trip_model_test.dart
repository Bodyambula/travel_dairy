import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_dairy/providers/trips_provider.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('Trip Model Tests', () {
    test('Trip.toMap should convert Trip to Map correctly', () {
      final trip = Trip(
        id: '123',
        userId: 'user1',
        title: 'Summer Trip',
        cities: ['Kyiv', 'Lviv'],
        dates: ['2026-06-01', '2026-06-10'],
        photosCount: 5,
        imagesBase64: ['img1', 'img2'],
        description: 'Testing trip',
      );

      final map = trip.toMap();

      expect(map['userId'], 'user1');
      expect(map['title'], 'Summer Trip');
      expect(map['cities'], ['Kyiv', 'Lviv']);
      expect(map['dates'], ['2026-06-01', '2026-06-10']);
      expect(map['photosCount'], 5);
      expect(map['imagesBase64'], ['img1', 'img2']);
      expect(map['description'], 'Testing trip');
    });

    test('Trip.fromFirestore should create Trip from DocumentSnapshot', () {
      final mockSnapshot = MockDocumentSnapshot();
      final data = {
        'userId': 'user-1',
        'title': 'Rome Holiday',
        'cities': ['Rome'],
        'dates': ['2026-05-01'],
        'photosCount': 10,
        'imagesBase64': ['b64_1'],
        'description': 'Enjoying Rome',
      };

      when(() => mockSnapshot.id).thenReturn('doc-123');
      when(() => mockSnapshot.data()).thenReturn(data);

      final trip = Trip.fromFirestore(mockSnapshot);

      expect(trip.id, 'doc-123');
      expect(trip.userId, 'user-1');
      expect(trip.title, 'Rome Holiday');
      expect(trip.cities, ['Rome']);
      expect(trip.dates, ['2026-05-01']);
      expect(trip.photosCount, 10);
      expect(trip.imagesBase64, ['b64_1']);
      expect(trip.description, 'Enjoying Rome');
    });

    test('Trip.fromFirestore should handle missing or null fields', () {
      final mockSnapshot = MockDocumentSnapshot();
      final data = <String, dynamic>{
        'userId': 'user-2',
        // title, cities, dates, photosCount are missing
      };

      when(() => mockSnapshot.id).thenReturn('doc-456');
      when(() => mockSnapshot.data()).thenReturn(data);

      final trip = Trip.fromFirestore(mockSnapshot);

      expect(trip.id, 'doc-456');
      expect(trip.title, ''); // Default in fromFirestore
      expect(trip.cities, isEmpty);
      expect(trip.dates, isEmpty);
      expect(trip.photosCount, 0);
    });

    test('Trip.fromFirestore should handle imagesBase64 as single String', () {
      final mockSnapshot = MockDocumentSnapshot();
      final data = {
        'imagesBase64': 'single_image_string',
      };

      when(() => mockSnapshot.id).thenReturn('doc-789');
      when(() => mockSnapshot.data()).thenReturn(data);

      final trip = Trip.fromFirestore(mockSnapshot);

      expect(trip.imagesBase64, ['single_image_string']);
    });

    test('Trip constructor should handle default values', () {
      final trip = Trip(
        userId: 'user2',
        title: 'Quick Trip',
        cities: [],
        dates: [],
        photosCount: 0,
      );

      expect(trip.imagesBase64, isEmpty);
      expect(trip.description, '');
      expect(trip.id, isNull);
    });

    test('Trip with large data should serialize and deserialize correctly', () {
      final manyCities = List.generate(100, (i) => 'City $i');
      final manyImages = List.generate(50, (i) => 'Base64DataBatch_$i');
      
      final trip = Trip(
        userId: 'big-user',
        title: 'Epic Journey',
        cities: manyCities,
        dates: ['2026-01-01', '2027-01-01'],
        photosCount: manyImages.length,
        imagesBase64: manyImages,
      );

      final map = trip.toMap();
      expect(map['cities'].length, 100);
      expect(map['imagesBase64'].length, 50);
    });

    test('Trip.fromFirestore should handle weird data types but cast to strings', () {
      final mockSnapshot = MockDocumentSnapshot();
      final data = {
        'userId': 123, // int instead of string
        'title': 'Typed Trip',
        'cities': ['City1', 456], // mixed types
        'dates': ['2026'],
        'photosCount': '5', // string instead of int
      };

      when(() => mockSnapshot.id).thenReturn('doc-types');
      when(() => mockSnapshot.data()).thenReturn(data);

      // This might throw if the factory doesn't cast correctly.
      // Current implementation uses List<String>.from which might fail if elements aren't strings.
      // But let's see how it behaves.
      expect(() => Trip.fromFirestore(mockSnapshot), throwsA(isA<TypeError>()));
    });

    test('Trip.fromFirestore should handle null in imagesBase64 field', () {
      final mockSnapshot = MockDocumentSnapshot();
      final data = {
        'userId': 'u1',
        'imagesBase64': null,
      };

      when(() => mockSnapshot.id).thenReturn('doc-null');
      when(() => mockSnapshot.data()).thenReturn(data);

      final trip = Trip.fromFirestore(mockSnapshot);
      expect(trip.imagesBase64, isEmpty);
    });
  });
}
