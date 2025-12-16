import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'add_trip_screen.dart';

import '../utils/AppStrings.dart';
import 'calendar_screen.dart';
import 'photos_screen.dart';
import 'settings_screen.dart';
import '../providers/trips_provider.dart';
import 'trip_details_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Змінна для збереження поточного індексу вкладки
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Завантаження даних
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Provider.of<TripsProvider>(context, listen: false).fetchTrips(user.uid);
      }
    });
  }

  /*
  final List<Map<String, String>> _travels = const [
    {
      'title': 'Італія 2025',
      'cities': 'Рим, Венеція, Флоренція',
      'dates': '15-28 лют',
      'photos': '45 фото',
    },
    {
      'title': 'Париж',
      'cities': 'Місто кохання та світла',
      'dates': '1-7 січ',
      'photos': '32 фото',
    },
    {
      'title': 'Іспанія',
      'cities': 'Барселона, Мадрид',
      'dates': '10-20 груд',
      'photos': '58 фото',
    },
  ];
*/
  Widget _buildHomeContent() {
    return Column(
      children: [
        // Хедер
        Container(
          width: double.infinity,
          color: const Color(0xFF1A3D8F),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Consumer<TripsProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      AppStrings.myTravels,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Динамічний лічильник подорожей
                    Text(
                      provider.isLoading
                          ? 'Оновлення...'
                          : '${provider.trips.length} подорожей збережено',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // Основний список з обробкою станів
        Expanded(
          child: Consumer<TripsProvider>(
            builder: (context, provider, child) {
              // 1. СТАН ЗАВАНТАЖЕННЯ
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. СТАН ПОМИЛКИ
              if (provider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            provider.fetchTrips(user.uid);
                          }
                        },
                        child: const Text('Спробувати знову'),
                      ),
                    ],
                  ),
                );
              }

              // 3. СТАН: ПУСТИЙ СПИСОК
              if (provider.trips.isEmpty) {
                return const Center(child: Text("Поки що немає подорожей"));
              }

              // 4. СТАН: УСПІШНЕ ВІДОБРАЖЕННЯ ДАНИХ
              return RefreshIndicator(
                onRefresh: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    provider.fetchTrips(user.uid);
                  }
                }, // Тут вже не треба async/await
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: provider.trips.length,
                  itemBuilder: (context, index) {
                    final trip = provider.trips[index];
                    return Card(
                      // Якщо є картинка, робимо фон прозорим (щоб картинка не перекривалась кольором)
                      // Якщо немає - залишаємо синій
                      color: const Color(0xFF1A3D8F),
                      elevation: 4,
                      clipBehavior: Clip
                          .antiAlias, // Щоб картинка обрізалась по краях картки
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TripDetailsScreen(trip: trip),
                            ),
                          );
                        },
                        child: Stack(
                          children: [


                            // 2. Контент поверх фону
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          trip.title,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(0, 1),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Кнопка видалення
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text(
                                                  'Видалити подорож?'),
                                              content: const Text(
                                                  'Ви впевнені, що хочете видалити цю подорож? Цю дію не можна скасувати.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                  },
                                                  child: const Text('Скасувати'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                    // Виклик методу видалення
                                                    if (trip.id != null) {
                                                      Provider.of<TripsProvider>(
                                                              context,
                                                              listen: false)
                                                          .deleteTrip(trip.id!);
                                                    }
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                  ),
                                                  child: const Text('Видалити'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    trip.cities.join(
                                      ', ',
                                    ), // Список міст через кому
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors
                                          .white70, // Трохи світліше, щоб читалось на фото
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey[300],
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        trip.dates.join(
                                          ' - ',
                                        ), // Дати через дефіс
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      const Icon(
                                        Icons.photo_camera_back,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${trip.photosCount} фото', // Число + текст
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    // Просто перемикаємо вкладку
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Список сторінок, між якими ми перемикаємось
    final List<Widget> pages = [
      _buildHomeContent(),
      const CalendarScreen(),
      const PhotosScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      // Показуємо віджет відповідно до вибраного індексу
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF1A3D8F),
              // Навігація на екран створення
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTripScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A56DB),
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        currentIndex: _selectedIndex, // Прив'язуємо до стану
        onTap: _onItemTapped, // Викликаємо наш метод
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: AppStrings.navCalendar,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: AppStrings.navPhotos,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}
