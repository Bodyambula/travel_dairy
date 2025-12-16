import 'package:flutter/material.dart';


class PhotoItem {
  final String id;
  final String
  emoji; 
  final String category;

  const PhotoItem({
    required this.id,
    required this.emoji,
    required this.category,
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
  static const Color bgLightBlue = Color(
    0xFFEBF2FA,
  ); 

  // Стан для вибраної категорії
  String _selectedCategory = 'Всі';

  // Список категорій
  final List<String> _categories = ['Всі', 'Італія', 'Франція', 'Іспанія'];

  // Статичні дані фотографій (відповідають макету)
  final List<PhotoItem> _allPhotos = [
    const PhotoItem(id: '1', emoji: '', category: 'Італія'),
    const PhotoItem(id: '2', emoji: '🗼', category: 'Франція'),
    const PhotoItem(id: '3', emoji: '', category: 'Іспанія'), 
    const PhotoItem(id: '4', emoji: '🌄', category: 'Італія'),
    const PhotoItem(id: '5', emoji: '🏰', category: 'Франція'),
    const PhotoItem(id: '6', emoji: '🌉', category: 'Іспанія'),
    const PhotoItem(id: '7', emoji: '🗽', category: 'Італія'),
    const PhotoItem(id: '8', emoji: '⛰️', category: 'Франція'),
    const PhotoItem(id: '9', emoji: '', category: 'Іспанія'), 
    const PhotoItem(id: '10', emoji: '🌃', category: 'Італія'),
    const PhotoItem(id: '11', emoji: '', category: 'Франція'),
    const PhotoItem(id: '12', emoji: '🌅', category: 'Іспанія'),
  ];

  // Геттер для отримання відфільтрованого списку
  List<PhotoItem> get _filteredPhotos {
    if (_selectedCategory == 'Всі') {
      return _allPhotos;
    }
    return _allPhotos
        .where((photo) => photo.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        toolbarHeight: 100,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Галерея',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textWhite,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '135 фото з подорожей',
              style: TextStyle(
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
          // 2. Фільтри (Горизонтальний список)
          _buildFilters(),

          // 3. Сітка фотографій
          _buildPhotoGrid(),
        ],
      ),
    );
  }

  // Віджет для фільтрів
  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Row(
        children: _categories.map((category) {
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              // Стилізація чіпів
              backgroundColor: bgLightBlue,
              selectedColor: primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? textWhite : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                // Прибираємо обводку
                side: const BorderSide(color: Colors.transparent),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Віджет для сітки фото
  Widget _buildPhotoGrid() {
    final photos = _filteredPhotos;

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 колонки, як на макеті
          crossAxisSpacing: 16, // Відступи між колонками
          mainAxisSpacing: 16, // Відступи між рядками
          childAspectRatio: 1, // Квадратні комірки
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return Container(
            decoration: BoxDecoration(
              color: bgLightBlue,
              borderRadius: BorderRadius.circular(20), // Заокруглені кути
            ),
            // Центруємо емодзі всередині картки
            child: Center(
              child: Text(photo.emoji, style: const TextStyle(fontSize: 48)),
            ),
          );
        },
      ),
    );
  }
}
