import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trips_provider.dart';
import '../utils/AppStrings.dart';

class PhotoItem {
  final String base64Image;
  final String tripTitle;

  const PhotoItem({
    required this.base64Image,
    required this.tripTitle,
  });
}

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  static const Color primaryBlue = Color(0xFF1A3D8F); 
  static const Color textWhite = Colors.white;
  static const Color bgLightBlue = Color(0xFFEBF2FA); 

  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final tripsProvider = Provider.of<TripsProvider>(context);
    final trips = tripsProvider.trips;
    final strings = AppStrings.of(context);

    // Збираємо всі фото
    final List<PhotoItem> allPhotos = [];
    final Set<String> tripTitles = {};

    for (var trip in trips) {
      if (trip.imagesBase64.isNotEmpty) {
        tripTitles.add(trip.title);
        for (var img in trip.imagesBase64) {
          allPhotos.add(PhotoItem(base64Image: img, tripTitle: trip.title));
        }
      }
    }

    final categories = [strings.categoryAll, ...tripTitles.toList()];
    
    // Якщо вибрана категорія більше не існує, скидаємо на "Всі"
    if (_selectedCategory == null || !categories.contains(_selectedCategory)) {
      _selectedCategory = strings.categoryAll;
    }

    // Фільтруємо фото
    final filteredPhotos = _selectedCategory == strings.categoryAll 
        ? allPhotos 
        : allPhotos.where((p) => p.tripTitle == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        toolbarHeight: 100,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              strings.galleryTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.photosTitleCount(allPhotos.length),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(categories),
          _buildPhotoGrid(filteredPhotos, strings),
        ],
      ),
    );
  }

  Widget _buildFilters(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Row(
        children: categories.map((category) {
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              backgroundColor: bgLightBlue,
              selectedColor: primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? textWhite : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(color: Colors.transparent),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhotoGrid(List<PhotoItem> photos, AppStrings strings) {
    if (photos.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            strings.noPhotos,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, 
          crossAxisSpacing: 16, 
          mainAxisSpacing: 16, 
          childAspectRatio: 1, 
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: EdgeInsets.zero,
                  child: Stack(
                     alignment: Alignment.center,
                    children: [
                      InteractiveViewer(
                        child: Image.memory(
                          base64Decode(photo.base64Image),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: bgLightBlue,
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: MemoryImage(base64Decode(photo.base64Image)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
