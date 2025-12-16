import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1E40AF);
    const Color textWhite = Colors.white;
    const Color bgGray = Color(0xFFF3F4F6); 

    return Scaffold(
      backgroundColor: Colors.white,
      // Верхня частина (Header + StatusBar імітується AppBar-ом)
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        toolbarHeight: 80, 
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              'Календар подорожей',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: textWhite,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Лютий 2025',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),

      // Основний контент
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Сітка календаря
              _buildCalendarGrid(primaryBlue, bgGray),

              const SizedBox(height: 24),

              // Секція "Подорожі цього місяця"
              const Text(
                'Подорожі цього місяця:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Картка подорожі
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '🇮🇹 Італія 2025',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '📅 15-28 лютого',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Color activeColor, Color inactiveColor) {
    final daysOfWeek = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

    const int emptySlots = 4;
    const int totalDays = 28;
    final List<int> activeDays = List.generate(
      14,
      (index) => 15 + index,
    ); 

    return Column(
      children: [
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: daysOfWeek
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),

        // Сітка днів
        GridView.builder(
          shrinkWrap:
              true,
          physics:
              const NeverScrollableScrollPhysics(), 
          itemCount: emptySlots + totalDays,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, 
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1, 
          ),
          itemBuilder: (context, index) {
            // Якщо це пустий слот
            if (index < emptySlots) {
              return const SizedBox();
            }

            // Вираховуємо реальний день місяця
            final dayNumber = index - emptySlots + 1;
            final isActive = activeDays.contains(dayNumber);

            return Container(
              decoration: BoxDecoration(
                color: isActive ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isActive ? Colors.white : Colors.black87,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
