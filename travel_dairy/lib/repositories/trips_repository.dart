import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/trips_provider.dart';

class TripsRepository {
  // Отримуємо доступ до колекції 'trips' у базі даних
  final CollectionReference _tripsCollection = FirebaseFirestore.instance
      .collection('trips');

  // Отримання списку
  Stream<List<Trip>> getTripsStream(String userId) {
    return _tripsCollection.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return Trip.fromFirestore(doc);
      }).toList();
    });
  }

  // Додавання нової подорожі
  Future<void> addTrip(Trip trip) async {
    await _tripsCollection.add(trip.toMap());
  }

  // Оновлення існуючої подорожі
  Future<void> updateTrip(Trip trip) async {
    if (trip.id == null) return;
    await _tripsCollection.doc(trip.id).update(trip.toMap());
  }

  // Видалення
  Future<void> deleteTrip(String tripId) async {
    await _tripsCollection.doc(tripId).delete();
  }
}
