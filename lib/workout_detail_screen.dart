import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Map<String, dynamic> workout;
  final String workoutId;

  const WorkoutDetailScreen({
    Key? key, 
    required this.workout, 
    required this.workoutId
  }) : super(key: key);

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool _isLoading = false;

  final List<String> keyExercises = ['Squat', 'Deadlift', 'Bench Press'];
  final Map<String, TextEditingController> weightControllers = {};
  final Map<String, TextEditingController> repControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each key exercise
    for (var exercise in keyExercises) {
      weightControllers[exercise] = TextEditingController();
      repControllers[exercise] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in [...weightControllers.values, ...repControllers.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
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
            Text(
              exercise,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
                  // Main card with workout info
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workoutDate,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.workout['title'] ?? 'Untitled Workout',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                            const Text(
                              'Notes:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.workout['notes'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Exercises',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (widget.workout['exercises'] != null &&
                      (widget.workout['exercises'] as List).isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (widget.workout['exercises'] as List).length,
                      itemBuilder: (context, index) {
                        final exercise = (widget.workout['exercises'] as List)[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(exercise['name'] ?? 'Exercise ${index + 1}'),
                            subtitle: Text(
                              'Sets: ${exercise['sets'] ?? '-'} • Reps: ${exercise['reps'] ?? '-'} • Weight: ${exercise['weight'] ?? '-'}kg',
                            ),
                          ),
                        );
                      },
                    )
                  else
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No exercises recorded for this workout.'),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  const Text(
                    'Add Lift Info',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  for (var exercise in keyExercises) _buildExerciseInput(exercise),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print("Current user: ${FirebaseAuth.instance.currentUser}");

          setState(() => _isLoading = true);

          final Map<String, Map<String, dynamic>> exerciseUpdates = {};

          for (var exercise in keyExercises) {
            final weight = weightControllers[exercise]?.text ?? '';
            final reps = repControllers[exercise]?.text ?? '';

            if (weight.isNotEmpty && reps.isNotEmpty) {
              exerciseUpdates[exercise] = {
                'weight': double.tryParse(weight),
                'reps': int.tryParse(reps),
              };
            }
          }

          try {
            final docRef = FirebaseFirestore.instance
              .collection('workoutData')
              .doc(widget.workout.id);

            await docRef.set({
              'liftData': exerciseUpdates,
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Workout data saved!')),
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
        child: const Icon(Icons.save), // changed from edit to save
      ),

    );
  }
}

extension on Map<String, dynamic> {
  String? get id => null;
}
