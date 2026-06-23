import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:travel_dairy/repositories/trips_repository.dart';
import 'package:travel_dairy/providers/trips_provider.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TripsRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = TripsRepository(firestore: fakeFirestore);
  });

  group('TripsRepository Unit Tests', () {
    test('addTrip should add a trip to Firestore', () async {
      final trip = Trip(
        userId: 'user1',
        title: 'New Trip',
        cities: ['Kyiv'],
        dates: ['2026-05-01'],
        photosCount: 0,
      );

      await repository.addTrip(trip);

      final snapshot = await fakeFirestore.collection('trips').get();
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['title'], 'New Trip');
      expect(snapshot.docs.first.data()['userId'], 'user1');
    });

    test('updateTrip should update existing trip', () async {
      // Add initial trip
      final docRef = await fakeFirestore.collection('trips').add({
        'userId': 'user1',
        'title': 'Old Title',
        'cities': [],
        'dates': [],
        'photosCount': 0,
      });

      final tripToUpdate = Trip(
        id: docRef.id,
        userId: 'user1',
        title: 'Updated Title',
        cities: ['Paris'],
        dates: ['2026-07-01'],
        photosCount: 2,
      );

      await repository.updateTrip(tripToUpdate);

      final docSnapshot = await fakeFirestore.collection('trips').doc(docRef.id).get();
      expect(docSnapshot.data()?['title'], 'Updated Title');
      expect(docSnapshot.data()?['cities'], ['Paris']);
    });

    test('deleteTrip should remove trip from Firestore', () async {
      final docRef = await fakeFirestore.collection('trips').add({
        'title': 'To Delete',
      });

      await repository.deleteTrip(docRef.id);

      final snapshot = await fakeFirestore.collection('trips').get();
      expect(snapshot.docs.length, 0);
    });

    test('getTripsStream should filter trips by userId', () async {
      // Add trips for different users
      await fakeFirestore.collection('trips').add({'userId': 'userA', 'title': 'Trip A'});
      await fakeFirestore.collection('trips').add({'userId': 'userA', 'title': 'Trip A2'});
      await fakeFirestore.collection('trips').add({'userId': 'userB', 'title': 'Trip B'});

      final stream = repository.getTripsStream('userA');
      final firstEmission = await stream.first;

      expect(firstEmission.length, 2);
      expect(firstEmission.every((t) => t.userId == 'userA'), isTrue);
    });

    test('getTripsStream should handle empty results', () async {
      final stream = repository.getTripsStream('nonexistent');
      final firstEmission = await stream.first;

      expect(firstEmission, isEmpty);
    });
  });
}
