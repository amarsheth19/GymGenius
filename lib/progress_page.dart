import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'tier_service.dart';
import 'package:intl/intl.dart';
import 'badge_service.dart';



//import 'package:your_app_name/workout_detail_screen.dart';
import 'workout_detail_screen.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});
  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final Set<DateTime> _workoutDays = {};
  List<Map<String, dynamic>> _workouts = [];
  bool _isLoading = true;
  Map<String, String> _badgeTiers = {};


  // Tier progress variables
  String _currentTier = 'bronze';
  int _currentPoints = 0;
  final Map<String, int> _tierRequirements = {
    'bronze': 0,
    'silver': 100,
    'gold': 200,
    'champion': 300,
  };

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    if (user != null) {
      _fetchWorkouts(); // already exists
      _loadBadgeTiers(); // <- NEW method
      _fetchUserTier();
    }
  }

  Stream<Map<String, String>> _badgeTierStream(String userId) {
    final badgeRef = FirebaseFirestore.instance
        .collection('badgeTiers')
        .doc(userId)
        .collection('badges');

    return badgeRef.snapshots().map((snapshot) {
      return {
        for (final doc in snapshot.docs) doc.id: doc['tier'] ?? 'none',
      };
    });
  }

  Future<void> _fetchUserTier() async {
  final doc = await _firestore.collection('userTiers').doc(user!.uid).get();
  if (doc.exists) {
    final data = doc.data()!;
    setState(() {
      _currentTier = data['tier'] ?? 'bronze';
      _currentPoints = data['points'] ?? 0;
    });
  }
}


  Future<void> _loadBadgeTiers() async {
    await _initializeBadgesIfNeeded(user!.uid);
    final badgeData = await fetchBadgeTiers(user!.uid);
    setState(() {
      _badgeTiers = badgeData;
    });
  }

  Future<void> _initializeBadgesIfNeeded(String userId) async {
    final badgeNames = [
      'Streak Starter',
      'Weekly Warrior',
      'Calendar Collector',
      'Champion Status',
      'Leg Day Loyalist',
    ];

    final badgeRef = FirebaseFirestore.instance
        .collection('badgeTiers')
        .doc(userId)
        .collection('badges');

    for (final badge in badgeNames) {
      final doc = await badgeRef.doc(badge).get();
      if (!doc.exists) {
        await badgeRef.doc(badge).set({'tier': 'bronze'});
      }
    }
  }


  Future<void> _fetchWorkouts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final workoutsSnapshot =
          await _firestore
              .collection('userWorkouts')
              .doc(user!.uid)
              .collection('workouts')
              .orderBy('date', descending: true)
              .get();

      final fetchedWorkouts =
          workoutsSnapshot.docs.map((doc) {
            final data = doc.data();
            // Add the document ID to the data
            return {'id': doc.id, ...data};
          }).toList();

      // Update workout days for calendar
      final workoutDates =
          fetchedWorkouts
              .where((workout) => workout['date'] != null)
              .map<DateTime>((workout) {
                final timestamp = workout['date'] as Timestamp;
                return timestamp.toDate();
              })
              .toSet();

      setState(() {
        _workouts = fetchedWorkouts;
        _workoutDays.clear();
        _workoutDays.addAll(workoutDates);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching workouts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }


  //ADDING WORKOUT TO CALENDER

  void _toggleWorkoutDay(DateTime day) async {
    final normalizedDay = DateTime(day.year, day.month, day.day);

    final workoutCollection = _firestore
        .collection('userWorkouts')
        .doc(user!.uid)
        .collection('workouts');

    final workoutsOnDay = _workouts.where((workout) {
      if (workout['date'] == null) return false;
      final workoutDate = (workout['date'] as Timestamp).toDate();
      return workoutDate.year == normalizedDay.year &&
          workoutDate.month == normalizedDay.month &&
          workoutDate.day == normalizedDay.day;
    }).toList();

    if (workoutsOnDay.isNotEmpty) {
      // 🗑 REMOVING WORKOUT LOGIC - CHANGES BADGES AND DASHBOARD
      for (final workout in workoutsOnDay) {
        try {
          // Delete from workoutData and userWorkouts
          await _firestore
              .collection('workoutData')
              .doc(user!.uid)
              .collection('workouts')
              .doc(workout['id'])
              .delete();

          await workoutCollection.doc(workout['id']).delete();

          // 🔁 Recompute max scores
          final remainingWorkoutsSnapshot = await _firestore
              .collection('workoutData')
              .doc(user!.uid)
              .collection('workouts')
              .get();

          Map<String, double> maxScores = {
            'Chest': 0.0,
            'Back': 0.0,
            'Abs': 0.0,
            'Left Arm': 0.0,
            'Right Arm': 0.0,
            'Left Leg': 0.0,
            'Right Leg': 0.0,
          };

          final Map<String, List<String>> exerciseToMuscles = {
            'Bench Press': ['Left Arm', 'Right Arm', 'Chest', 'Abs'],
            'Deadlift': ['Back', 'Abs'],
            'Squat': ['Left Leg', 'Right Leg', 'Abs'],
          };

          double calculateScore(int reps, double weight, String exercise) {
            final ex = exercise.toLowerCase();

            final Map<String, double> multipliers = {
              'bench press': 1.0,
              'squat': 0.75,
              'deadlift': 0.6,
            };

            final Map<String, double> reference = {
              'bench press': 265.0,
              'squat': 353.0,
              'deadlift': 441.0,
            };

            if (!multipliers.containsKey(ex)) {
              return 0.0;
            }

            final oneRm = weight * (1.0 + reps / 30.0);
            final adjustedRm = oneRm * multipliers[ex]!;
            double score = (adjustedRm / reference[ex]!) * 100.0;
            score = score.clamp(0.0, 100.0);
            score = (score * 10).roundToDouble() / 10.0;
            return score;
          }

          String getTierFromScore(double score) {
            if (score >= 75) return 'CHAMPION';
            if (score >= 50) return 'GOLD';
            if (score >= 25) return 'SILVER';
            return 'BRONZE';
          }

          for (final doc in remainingWorkoutsSnapshot.docs) {
            final liftData = doc.data()['liftData'] as Map<String, dynamic>?;

            if (liftData != null) {
              for (final entry in liftData.entries) {
                final exercise = entry.key;
                final details = entry.value;
                final reps = (details['reps'] ?? 0) as int;
                final weight = (details['weight'] ?? 0.0) as double;
                final score = calculateScore(reps, weight, exercise);

                final muscles = exerciseToMuscles[exercise] ?? [];
                for (final muscle in muscles) {
                  if (score > maxScores[muscle]!) {
                    maxScores[muscle] = score;
                  }
                }
              }
            }
          }

          final muscleRef = _firestore
              .collection('userRanks')
              .doc(user!.uid)
              .collection('muscleGroups');

          for (final entry in maxScores.entries) {
            final muscle = entry.key;
            final score = entry.value;
            final tier = getTierFromScore(score);

            await muscleRef.doc(muscle).set({
              'rank': tier,
              'score': score,
            });
          }

        } catch (e) {
          print('Error during workout + rank deletion: $e');
        }
      }
    } else {
      // ➕ Add workout if one doesn't exist
      final workoutData = {
        'date': Timestamp.fromDate(normalizedDay),
        'title': 'Workout on ${DateFormat('MMM d').format(normalizedDay)}',
        'exercises': [],
        'notes': 'Added from progress page',
      };

      try {
        await workoutCollection.add(workoutData);
      } catch (e) {
        print('Error adding workout: $e');
      }
    }

    // 🔁 Always update points, badge tiers, and refresh state
    await _fetchWorkouts(); // repopulates _workouts list
    await fetchAndUpdateBadgeTiers(user!.uid);
    final points = await calculateUserPoints(user!.uid);
    await updateUserTier(user!.uid, points);
    await _fetchUserTier(); // ✅ this makes the progress bar refresh

    setState(() {}); // optional, ensures UI redraws
  }



  @override
  Widget build(BuildContext context) {
    // Calculate tier progress
    final tiers = _tierRequirements.keys.toList();
    final currentIndex = tiers.indexOf(_currentTier);
    final nextTier = currentIndex < tiers.length - 1 ? tiers[currentIndex + 1] : null;

    final currentThreshold = _tierRequirements[_currentTier]!;
    final nextThreshold = nextTier != null
        ? _tierRequirements[nextTier]!
        : currentThreshold;

    final progressPoints = _currentPoints - currentThreshold;
    final requiredPoints = nextThreshold - currentThreshold;
    final progressFraction = nextTier != null
        ? progressPoints / requiredPoints
        : 1.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Progress Tracking')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF181C2F), Color(0xFF2196F3)], // black to blue
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
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
                                  color: _getTierColor(
                                    _currentTier,
                                  ).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getTierColor(_currentTier),
                                    width: 2,
                                  ),
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
                                        'Progress to ${nextTier![0].toUpperCase()}${nextTier.substring(1)}: $progressPoints / $requiredPoints points',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      )
                                    else
                                      const Text(
                                        'You\'ve reached the highest tier!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: progressFraction.clamp(0.0, 1.0),
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
                    'Total Workouts',
                    '${_workoutDays.length} days',
                    Icons.fitness_center,
                  ),
                  // const SizedBox(height: 15),
                  // _buildProgressCard(
                  //   'Weight Change',
                  //   '-2.5 kg',
                  //   Icons.monitor_weight,
                  // ),
                  // const SizedBox(height: 15),
                  // _buildProgressCard(
                  //   'Running Distance',
                  //   '15.3 km',
                  //   Icons.directions_run,
                  // ),
                  const SizedBox(height: 25),

                  // Recent Workouts List
                  const Text(
                    'Recent Workouts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _workouts.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No workouts found. Start adding your workouts!',
                          ),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _workouts.length > 5 ? 5 : _workouts.length,
                        itemBuilder: (context, index) {
                          final workout = _workouts[index];
                          final workoutDate =
                              workout['date'] != null
                                  ? DateFormat('MMM d, yyyy').format(
                                    (workout['date'] as Timestamp).toDate(),
                                  )
                                  : 'No date';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            child: ListTile(
                              leading: const Icon(
                                Icons.fitness_center,
                                color: Colors.blue,
                              ),
                              title: Text(workout['title'] ?? 'Untitled Workout'),
                              subtitle: Text(workoutDate),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // Navigate to the workout detail screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => WorkoutDetailScreen(
                                          workout: workout,
                                          workoutId: workout['id'],
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                  if (_workouts.length > 5)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to full workout history page
                          // You can implement this based on your app's navigation
                        },
                        child: const Text(
                          'View All Workouts',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
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
                            if (_workoutDays.any(
                              (workoutDay) =>
                                  workoutDay.year == normalizedDay.year &&
                                  workoutDay.month == normalizedDay.month &&
                                  workoutDay.day == normalizedDay.day,
                            )) {
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
                        _workoutDays.any(
                              (d) =>
                                  d.year == _selectedDay.year &&
                                  d.month == _selectedDay.month &&
                                  d.day == _selectedDay.day,
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
                  StreamBuilder<Map<String, String>>(
                    stream: _badgeTierStream(user!.uid),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final badgeTiers = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBadgeCard('Streak Starter', badgeTiers['Streak Starter'] ?? 'none'),
                          _buildBadgeCard('Weekly Warrior', badgeTiers['Weekly Warrior'] ?? 'none'),
                          _buildBadgeCard('Calendar Collector', badgeTiers['Calendar Collector'] ?? 'none'),
                          _buildBadgeCard('Champion Status', badgeTiers['Champion Status'] ?? 'none'),
                          _buildBadgeCard('Leg Day Loyalist', badgeTiers['Leg Day Loyalist'] ?? 'none'),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
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

  Widget _buildBadgeCard(String badgeName, String tier) {
    final Color tierColor = _getTierColor(tier);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.verified, size: 40, color: tierColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                badgeName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tierColor),
              ),
              child: Text(
                tier.toUpperCase(),
                style: TextStyle(
                  color: tierColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          Text('$percentage% of goal achieved'),
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

extension on Object {
  delete() {}
}
