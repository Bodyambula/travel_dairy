import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/trips_repository.dart';

class Trip {
  final String? id;
  final String userId;
  final String title;
  final List<String> cities;
  final List<String> dates;
  final int photosCount;
  final List<String> imagesBase64;
  final String description;

  Trip({
    this.id,
    required this.userId,
    required this.title,
    required this.cities,
    required this.dates,
    required this.photosCount,
    this.imagesBase64 = const [],
    this.description = '',
  });

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<String> images = [];

    var rawImages = data['imagesBase64'];

    if (rawImages != null) {
      if (rawImages is List) {
        images = List<String>.from(rawImages);
      } else if (rawImages is String) {
        images = [rawImages];
      }
    }

    return Trip(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      cities: List<String>.from(data['cities'] ?? []),
      dates: List<String>.from(data['dates'] ?? []),
      photosCount: data['photosCount'] ?? 0,
      imagesBase64: images,
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'cities': cities,
      'dates': dates,
      'photosCount': photosCount,
      'imagesBase64': imagesBase64, // Save as list
      'description': description,
    };
  }
}

class TripsProvider with ChangeNotifier {
  final TripsRepository _repository = TripsRepository();

  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // завантаження даних
  void fetchTrips(String userId) {
    _isLoading = true;
    notifyListeners();

    try {
      // Слухаємо потік даних з Firebase
      _repository
          .getTripsStream(userId)
          .listen(
            (tripsData) {
              _trips = tripsData;
              _isLoading = false;
              notifyListeners(); // Оновлюємо інтерфейс, коли приходять нові дані
            },
            onError: (error) {
              _errorMessage = error.toString();
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Метод для додавання
  Future<void> addTrip(Trip trip) async {
    await _repository.addTrip(trip);
  }

  Future<void> updateTrip(Trip trip) async {
    try {
      await _repository.updateTrip(trip);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteTrip(String id) async {
    try {
      await _repository.deleteTrip(id);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
