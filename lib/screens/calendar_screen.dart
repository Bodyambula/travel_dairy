import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/trips_provider.dart';
import 'trip_details_screen.dart';
import '../utils/AppStrings.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  Trip? _getTripForDay(int day, List<Trip> trips) {
    DateTime date = DateTime(_currentMonth.year, _currentMonth.month, day);
    final dateFormat = DateFormat('dd.MM.yyyy');

    for (var trip in trips) {
      if (trip.dates.length >= 2) {
        try {
          DateTime start = dateFormat.parse(trip.dates.first);
          DateTime end = dateFormat.parse(trip.dates.last);
          
          DateTime pureStart = DateTime(start.year, start.month, start.day);
          DateTime pureEnd = DateTime(end.year, end.month, end.day);
          DateTime pureDate = DateTime(date.year, date.month, date.day);

          if ((pureDate.isAfter(pureStart) || pureDate.isAtSameMomentAs(pureStart)) &&
              (pureDate.isBefore(pureEnd) || pureDate.isAtSameMomentAs(pureEnd))) {
            return trip;
          }
        } catch (e) {
          // ignore
        }
      }
    }
    return null;
  }

  List<Trip> _getTripsForCurrentMonth(List<Trip> trips) {
    Set<Trip> monthTrips = {};
    for (int day = 1; day <= _daysInMonth(_currentMonth); day++) {
      final trip = _getTripForDay(day, trips);
      if (trip != null) {
        monthTrips.add(trip);
      }
    }
    return monthTrips.toList();
  }

  int _daysInMonth(DateTime date) {
    var firstDayNextMonth = (date.month < 12) 
        ? DateTime(date.year, date.month + 1, 1) 
        : DateTime(date.year + 1, 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }

  int _firstDayOffset(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday - 1; // 0 for Monday
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1E40AF);
    const Color textWhite = Colors.white;
    const Color bgGray = Color(0xFFF3F4F6); 

    final tripsProvider = Provider.of<TripsProvider>(context);
    final monthTrips = _getTripsForCurrentMonth(tripsProvider.trips);
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        toolbarHeight: 80, 
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              strings.calendarTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: textWhite,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: _previousMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Text(
                  strings.monthYearFormat(_currentMonth.month, _currentMonth.year),
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: _nextMonth,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendarGrid(primaryBlue, bgGray, tripsProvider.trips, strings),
              const SizedBox(height: 24),
              Text(
                strings.thisMonthTrips,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              if (monthTrips.isEmpty)
                Text(
                  strings.noTripsThisMonth,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                )
              else
                ...monthTrips.map((trip) => _buildTripCard(trip, primaryBlue)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip, Color primaryBlue) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsScreen(trip: trip),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          children: [
            Text(
              trip.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '📅 ${trip.dates.join(' - ')}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Color activeColor, Color inactiveColor, List<Trip> trips, AppStrings strings) {
    final daysOfWeek = strings.daysOfWeek;

    final int emptySlots = _firstDayOffset(_currentMonth);
    final int totalDays = _daysInMonth(_currentMonth);

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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), 
          itemCount: emptySlots + totalDays,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, 
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1, 
          ),
          itemBuilder: (context, index) {
            if (index < emptySlots) {
              return const SizedBox();
            }

            final dayNumber = index - emptySlots + 1;
            final trip = _getTripForDay(dayNumber, trips);
            final isActive = trip != null;

            return GestureDetector(
              onTap: () {
                if (isActive) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripDetailsScreen(trip: trip),
                    ),
                  );
                }
              },
              child: Container(
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
              ),
            );
          },
        ),
      ],
    );
  }
}
