import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../utils/AppStrings.dart';

class RouteMapScreen extends StatefulWidget {
  final List<String> cities;

  const RouteMapScreen({super.key, required this.cities});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  bool _isLoading = true;
  String? _error;
  bool _didInit = false;
  
  List<LatLng> _cityCoordinates = [];
  List<LatLng> _routePoints = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      final strings = AppStrings.of(context);
      _buildRoute(strings);
    }
  }

  Future<void> _buildRoute(AppStrings strings) async {
    try {
      // 1. Geocode cities using OpenStreetMap Nominatim
      List<LatLng> coords = [];
      for (String city in widget.cities) {
        final uri = Uri.parse('https://nominatim.openstreetmap.org/search?q=$city&format=json&limit=1');
        final response = await http.get(uri, headers: {
          'User-Agent': 'TravelDiary/1.0 (test@example.com)'
        });
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            double lat = double.parse(data[0]['lat']);
            double lon = double.parse(data[0]['lon']);
            coords.add(LatLng(lat, lon));
          }
        }
      }

      if (coords.length < 2) {
        throw Exception(strings.errorNoCitiesForRoute);
      }

      // 2. Build connection via OSRM (Driving route)
      String coordinatesString = coords.map((c) => '${c.longitude},${c.latitude}').join(';');
      final osrmUrl = Uri.parse('http://router.project-osrm.org/route/v1/driving/$coordinatesString?geometries=geojson');
      final routeRes = await http.get(osrmUrl);

      List<LatLng> routePoints = [];
      if (routeRes.statusCode == 200) {
        final routeData = jsonDecode(routeRes.body);
        if (routeData['routes'] != null && routeData['routes'].isNotEmpty) {
          final geometry = routeData['routes'][0]['geometry'];
          final List coordinates = geometry['coordinates'];
          for (var point in coordinates) {
            // GeoJSON returns [lon, lat]
            routePoints.add(LatLng(point[1], point[0]));
          }
        }
      } else {
        // Fallback to straight lines if route fails
        routePoints = coords;
      }

      if (mounted) {
        setState(() {
          _cityCoordinates = coords;
          _routePoints = routePoints;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  LatLngBounds _getBounds() {
    if (_routePoints.isEmpty && _cityCoordinates.isEmpty) {
      return LatLngBounds(const LatLng(0, 0), const LatLng(0, 0));
    }
    
    final allPoints = [..._routePoints, ..._cityCoordinates];
    
    double minLat = allPoints.first.latitude;
    double maxLat = minLat;
    double minLng = allPoints.first.longitude;
    double maxLng = minLng;

    for (var point in allPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    
    // Add some padding
    final latPadding = (maxLat - minLat) * 0.1;
    final lngPadding = (maxLng - minLng) * 0.1;

    return LatLngBounds(
      LatLng(minLat - latPadding, minLng - lngPadding),
      LatLng(maxLat + latPadding, maxLng + lngPadding),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.buildRouteBtn),
        backgroundColor: const Color(0xFF1A3D8F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(strings.mapLoading),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(strings.mapError, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          _error!, 
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : FlutterMap(
                  options: MapOptions(
                    initialCameraFit: CameraFit.bounds(
                      bounds: _getBounds(),
                      padding: const EdgeInsets.all(40),
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'ua.travel_diary.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 4.0,
                          color: const Color(0xFF1A3D8F),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: _cityCoordinates.map((coord) {
                        return Marker(
                          point: coord,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
    );
  }
}
