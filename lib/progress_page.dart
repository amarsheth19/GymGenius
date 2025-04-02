import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
      ),
      body: Padding(
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
              _buildProgressCard('Weekly Workouts', '5/7 days', Icons.fitness_center),
              const SizedBox(height: 15),
              _buildProgressCard('Weight Change', '-2.5 kg', Icons.monitor_weight),
              const SizedBox(height: 15),
              _buildProgressCard('Running Distance', '15.3 km', Icons.directions_run),
              const SizedBox(height: 25),
              const Text(
                'Monthly Trends',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _buildTrendItem('Week 1', 70),
                    _buildTrendItem('Week 2', 80),
                    _buildTrendItem('Week 3', 90),
                    _buildTrendItem('Week 4', 85),
                  ],
                ),
              ),
            ],
          ],
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
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
          Text(
            week,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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
}