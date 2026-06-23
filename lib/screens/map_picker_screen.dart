import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../utils/AppStrings.dart';

class PickedPoint {
  final LatLng point;
  String? cityName;
  bool isLoading;
  bool hasError;

  PickedPoint({
    required this.point,
    this.cityName,
    this.isLoading = true,
    this.hasError = false,
  });
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final List<PickedPoint> _points = [];
  bool _isReversing = false;

  void _handleTap(TapPosition tapPosition, LatLng latlng) async {
    final newPoint = PickedPoint(point: latlng);
    setState(() {
      _points.add(newPoint);
      _isReversing = true;
    });

    final strings = AppStrings.of(context, listen: false);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${latlng.latitude}&lon=${latlng.longitude}&format=json',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'TravelDiary/1.0 (test@example.com)'
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['address'] != null) {
          final address = data['address'];
          // Try to extract city, town, or village
          String? city = address['city'] ?? address['town'] ?? address['village'] ?? address['municipality'];
          
          if (city != null) {
            setState(() {
              newPoint.cityName = city;
              newPoint.isLoading = false;
            });
          } else {
            // No city found
            setState(() {
              newPoint.hasError = true;
              newPoint.isLoading = false;
            });
            _showError(strings.errorCityNotFound);
          }
        } else {
          setState(() {
            newPoint.hasError = true;
            newPoint.isLoading = false;
          });
          _showError(strings.errorCityNotFound);
        }
      } else {
         setState(() {
            newPoint.hasError = true;
            newPoint.isLoading = false;
          });
          _showError(strings.errorCityNotFound);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          newPoint.hasError = true;
          newPoint.isLoading = false;
        });
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReversing = _points.any((p) => p.isLoading);
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removePoint(int index) {
    setState(() {
      _points.removeAt(index);
    });
  }

  void _done() {
    // Return only fully loaded and valid city names
    final cities = _points
        .where((p) => !p.isLoading && !p.hasError && p.cityName != null)
        .map((p) => p.cityName!)
        .toList();
    Navigator.pop(context, cities);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.mapPickerTitle),
        backgroundColor: const Color(0xFF1A3D8F),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _points.isEmpty ? null : _done,
            child: Text(
              strings.mapPickerDone,
              style: TextStyle(
                color: _points.isEmpty ? Colors.white54 : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              // Default to Ukraine center approx.
              initialCenter: const LatLng(49.0, 31.0),
              initialZoom: 5.5,
              onTap: _handleTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ua.travel_diary.app',
              ),
              MarkerLayer(
                markers: _points.map((p) {
                  return Marker(
                    point: p.point,
                    width: 120,
                    height: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (p.isLoading)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else if (p.hasError)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.error, color: Colors.red, size: 16),
                          )
                        else if (p.cityName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: Text(
                              p.cityName!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A3D8F),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          // Instruction overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2)
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app, color: Color(0xFF1A3D8F)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.mapPickerInstruction,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom list of picked cities
          if (_points.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _points.length,
                        itemBuilder: (context, index) {
                          final p = _points[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF1A3D8F).withOpacity(0.1),
                              child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF1A3D8F))),
                            ),
                            title: p.isLoading 
                              ? Text(strings.mapPickerFetching, style: const TextStyle(color: Colors.grey))
                              : p.hasError
                                ? Text(strings.errorCityNotFound, style: const TextStyle(color: Colors.red))
                                : Text(p.cityName!),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => _removePoint(index),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
