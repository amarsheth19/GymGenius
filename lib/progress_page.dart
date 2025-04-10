import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final user = FirebaseAuth.instance.currentUser;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final Set<DateTime> _workoutDays = {};
  
  // Tier progress variables
  final String _currentTier = 'silver'; // Example: current tier
  final int _currentPoints = 650; // Example: current points
  final Map<String, int> _tierRequirements = {
    'bronze': 0,
    'silver': 500,
    'gold': 1000,
    'champion': 2000,
  };
  
  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _workoutDays.addAll([
      DateTime.now().subtract(const Duration(days: 2)),
      DateTime.now().subtract(const Duration(days: 4)),
      DateTime.now().subtract(const Duration(days: 5)),
      DateTime.now().add(const Duration(days: 1)),
    ]);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _toggleWorkoutDay(DateTime day) {
    setState(() {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      if (_workoutDays.contains(normalizedDay)) {
        _workoutDays.remove(normalizedDay);
      } else {
        _workoutDays.add(normalizedDay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate tier progress
    final tiers = _tierRequirements.keys.toList();
    final currentIndex = tiers.indexOf(_currentTier);
    final nextTier = currentIndex < tiers.length - 1 ? tiers[currentIndex + 1] : null;
    final currentRequirement = _tierRequirements[_currentTier]!;
    final nextRequirement = nextTier != null ? _tierRequirements[nextTier]! : _tierRequirements[_currentTier]!;
    final progress = nextTier != null 
        ? (_currentPoints - currentRequirement) / (nextRequirement - currentRequirement)
        : 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Progress Tracking')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user == null)
                const Center(
                  child: Text(
                    'Please sign in to view your progress',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              else ...[
                const Text(
                  'Your Fitness Journey',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Tier Progress Section
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tier Progress',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getTierColor(_currentTier).withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: _getTierColor(_currentTier), width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  _currentTier[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _getTierColor(_currentTier),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Tier: ${_currentTier[0].toUpperCase()}${_currentTier.substring(1)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  if (nextTier != null)
                                    Text(
                                      'Progress to ${nextTier[0].toUpperCase()}${nextTier.substring(1)}: ${(_currentPoints - currentRequirement)}/${nextRequirement - currentRequirement} points',
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    )
                                  else
                                    const Text(
                                      'You\'ve reached the highest tier!',
                                      style: TextStyle(fontSize: 14, color: Colors.green),
                                    ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getTierColor(_currentTier),
                                    ),
                                    minHeight: 10,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                _buildProgressCard(
                  'Weekly Workouts',
                  '${_workoutDays.length} days',
                  Icons.fitness_center,
                ),
                const SizedBox(height: 15),
                _buildProgressCard(
                  'Weight Change',
                  '-2.5 kg',
                  Icons.monitor_weight,
                ),
                const SizedBox(height: 15),
                _buildProgressCard(
                  'Running Distance',
                  '15.3 km',
                  Icons.directions_run,
                ),
                const SizedBox(height: 25),
                const Text(
                  'Workout Calendar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate:
                          (day) => isSameDay(_selectedDay, day),
                      onDaySelected: _onDaySelected,
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        markersAlignment: Alignment.bottomCenter,
                        outsideDaysVisible: false,
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, day, events) {
                          final normalizedDay = DateTime(
                            day.year,
                            day.month,
                            day.day,
                          );
                          if (_workoutDays.contains(normalizedDay)) {
                            return Positioned(
                              bottom: 1,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _toggleWorkoutDay(_selectedDay),
                    child: Text(
                      _workoutDays.contains(
                            DateTime(
                              _selectedDay.year,
                              _selectedDay.month,
                              _selectedDay.day,
                            ),
                          )
                          ? 'Remove Workout for ${DateFormat('MMM d').format(_selectedDay)}'
                          : 'Add Workout for ${DateFormat('MMM d').format(_selectedDay)}',
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Badge Progress',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200, // Fixed height for the trends section
                  child: ListView(
                    children: [
                      _buildTrendItem('Badge 1', 70),
                      _buildTrendItem('Badge 2', 80),
                      _buildTrendItem('Badge 3', 90),
                      _buildTrendItem('Badge 4', 85),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(String week, int percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(week, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            minHeight: 10,
          ),
          const SizedBox(height: 4),
          Text('${percentage}% of goal achieved'),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'champion':
        return const Color(0xFFE0115F);
      default:
        return Colors.blue;
    }
  }
}