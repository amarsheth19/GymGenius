import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'badge_service.dart';


class WorkoutDetailScreen extends StatefulWidget {
  final Map<String, dynamic> workout;
  final String workoutId;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
    required this.workoutId,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool _isLoading = false;

  final List<String> keyExercises = ['Squat', 'Deadlift', 'Bench Press'];
  final Map<String, TextEditingController> weightControllers = {};
  final Map<String, TextEditingController> repControllers = {};

  final Map<String, List<String>> exerciseToMuscles = {
    'Bench Press': ['Left Arm', 'Right Arm', 'Chest', 'Abs'],
    'Deadlift': ['Back', 'Abs'],
    'Squat': ['Left Leg', 'Right Leg', 'Abs'],
  };

  double calculateScore(int reps, double weight) {
    return reps * weight * 0.1;
  }

  String getTierFromScore(double score) {
    if (score >= 75) return 'CHAMPION';
    if (score >= 50) return 'GOLD';
    if (score >= 25) return 'SILVER';
    return 'BRONZE';
  }

  @override
  void initState() {
    super.initState();

    for (var exercise in keyExercises) {
      weightControllers[exercise] = TextEditingController();
      repControllers[exercise] = TextEditingController();
    }

    _loadExistingLiftData(); // new method
  }


  @override
  void dispose() {
    for (var controller in [...weightControllers.values, ...repControllers.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingLiftData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('workoutData')
        .doc(user.uid)
        .collection('workouts')
        .doc(widget.workoutId);

    final snapshot = await docRef.get();
    final data = snapshot.data();

    if (data != null && data.containsKey('liftData')) {
      final liftData = data['liftData'] as Map<String, dynamic>;

      for (var exercise in keyExercises) {
        if (liftData.containsKey(exercise)) {
          final details = liftData[exercise] as Map<String, dynamic>;
          weightControllers[exercise]?.text = (details['weight'] ?? '').toString();
          repControllers[exercise]?.text = (details['reps'] ?? '').toString();
        }
      }
    }
  }


  Future<void> _saveWorkoutData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final firestore = FirebaseFirestore.instance;
    final docRef = firestore
        .collection('workoutData')
        .doc(user.uid)
        .collection('workouts')
        .doc(widget.workoutId);

    final Map<String, Map<String, dynamic>> exerciseUpdates = {};

    for (var exercise in keyExercises) {
      final weight = weightControllers[exercise]?.text ?? '';
      final reps = repControllers[exercise]?.text ?? '';

      if (weight.isNotEmpty && reps.isNotEmpty) {
        final w = double.tryParse(weight);
        final r = int.tryParse(reps);
        if (w != null && r != null) {
          exerciseUpdates[exercise] = {
            'weight': w,
            'reps': r,
          };

          final score = calculateScore(r, w);
          final newTier = getTierFromScore(score);

          final affectedMuscles = exerciseToMuscles[exercise];
          if (affectedMuscles != null) {
            for (final muscle in affectedMuscles) {
              final muscleRef = firestore
                  .collection('userRanks')
                  .doc(user.uid)
                  .collection('muscleGroups')
                  .doc(muscle);

              final muscleDoc = await muscleRef.get();
              final currentScore = muscleDoc.exists ? (muscleDoc.data()!['score'] ?? 0.0) : 0.0;

              if (score > currentScore) {
                await muscleRef.set({
                  'rank': newTier,
                  'score': score,
                });
              }
            }
          }
        }
      }
    }

    await docRef.set({
      'liftData': exerciseUpdates,
      'metadata': {
        'title': widget.workout['title'],
        'duration': widget.workout['duration'],
        'startTime': widget.workout['startTime'],
        'endTime': widget.workout['endTime'],
        'notes': widget.workout['notes'],
        'userEmail': widget.workout['userEmail'],
        'date': widget.workout['date'],
      },
    });

    await fetchAndUpdateBadgeTiers(user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final workoutDate = widget.workout['date'] != null
        ? DateFormat('EEEE, MMM d, yyyy').format((widget.workout['date'] as Timestamp).toDate())
        : 'No date';

    final startTime = widget.workout['startTime'] != null
        ? DateFormat('h:mm a').format((widget.workout['startTime'] as Timestamp).toDate())
        : 'N/A';

    final endTime = widget.workout['endTime'] != null
        ? DateFormat('h:mm a').format((widget.workout['endTime'] as Timestamp).toDate())
        : 'N/A';

    final duration = widget.workout['duration'] != null
        ? '${widget.workout['duration']} seconds'
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout['title'] ?? 'Workout Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(workoutDate, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text(widget.workout['title'] ?? 'Untitled Workout', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildInfoRow('Start Time', startTime),
                          _buildInfoRow('End Time', endTime),
                          _buildInfoRow('Duration', duration),
                          if (widget.workout['userEmail'] != null)
                            _buildInfoRow('User', widget.workout['userEmail']),
                          if (widget.workout['notes'] != null) ...[
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text('Notes:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(widget.workout['notes'], style: const TextStyle(fontSize: 16)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Add Lift Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  for (var exercise in keyExercises) _buildExerciseInput(exercise),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() => _isLoading = true);
          try {
            await _saveWorkoutData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Workout data and ranks updated!')),
              );
            }
          } catch (e) {
            debugPrint('Error saving to Firestore: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to save data')),
              );
            }
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInput(String exercise) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: weightControllers[exercise],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: repControllers[exercise],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
