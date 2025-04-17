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

  @override
  Widget build(BuildContext context) {
    // Format date if available
    final workoutDate = widget.workout['date'] != null 
        ? DateFormat('EEEE, MMM d, yyyy').format((widget.workout['date'] as Timestamp).toDate())
        : 'No date';
    
    // Format start time if available
    final startTime = widget.workout['startTime'] != null 
        ? DateFormat('h:mm a').format((widget.workout['startTime'] as Timestamp).toDate())
        : 'N/A';
    
    // Format end time if available
    final endTime = widget.workout['endTime'] != null 
        ? DateFormat('h:mm a').format((widget.workout['endTime'] as Timestamp).toDate())
        : 'N/A';
    
    // Get duration in minutes
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
                          
                          // Workout duration and time information
                          _buildInfoRow('Start Time', startTime),
                          _buildInfoRow('End Time', endTime),
                          _buildInfoRow('Duration', duration),
                          
                          // User information
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Display exercises if they exist
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
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to edit workout screen
          // You can implement this later
        },
        child: const Icon(Icons.edit),
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
}