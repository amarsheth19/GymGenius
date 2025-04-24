import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Map<String, String> _muscleRanks = {};

  @override
  void initState() {
    super.initState();
    _fetchMuscleRanks();
  }

  Future<void> _fetchMuscleRanks() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('userRanks')
        .doc(user.uid)
        .collection('muscleGroups')
        .get();

    final expectedMuscles = [
      'Chest', 'Back', 'Abs', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg'
    ];

    final data = {
      for (var doc in snapshot.docs)
        if (expectedMuscles.contains(doc.id)) doc.id: doc['rank'] as String,
    };

    setState(() => _muscleRanks = data);
  }

  String _getRank(String muscle) {
    return _muscleRanks[muscle] ?? 'Loading...';
  }

  bool _isChecked(String muscle) {
    return _getRank(muscle).contains('GOLD');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Muscle Map'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24),
              _buildInteractiveBodyGraph(context),
              const SizedBox(height: 24),
              _buildMuscleRankingsSection(),
            ],
          ),
        ),
      ),
    );
  }


  // ========== CORE COMPONENTS ========== //

 Widget _buildInteractiveBodyGraph(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: CustomPaint(
              painter: _BodyPainter(),
              child: Stack(
                children: [
                  Positioned(
                    top: 5, // Adjust the position to place it above the torso
                    left: 120, // Center it horizontally
                    child: Container(
                      width: 40, // Circular head width
                      height: 40, // Circular head height
                      decoration: BoxDecoration(
                        color: Colors.grey, // Head color
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Chest and Back
                  _buildMuscleZone(context, 'Back', 120, 25, 80, 55),
                  _buildMuscleZone(context, 'Chest', 120, 70, 80, 80),
                  _buildMuscleZone(context, 'Left Arm', 40, 100, 40, 70),
                  _buildMuscleZone(context, 'Right Arm', 40, 100, 200, 70),
                  _buildMuscleZone(context, 'Abs', 65, 65, 110, 135),
                  _buildMuscleZone(context, 'Left Leg', 50, 100, 80, 190),
                  _buildMuscleZone(context, 'Right Leg', 50, 100, 150, 190),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMuscleButtonsRow(context),
        ],
      ),
    );
  }

  // ========== MUSCLE ZONES ========== //
  Widget _buildMuscleZone(
    BuildContext context,
    String name,
    double width,
    double height,
    double left,
    double top,
  ) {
    final rank = _muscleRanks[name] ?? '';
    final color = _getColorFromRank(rank);

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => _showMuscleDetails(context, name, color),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              name.split(' ').first,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }




    // ========== BUTTON ROW ========== //

  Widget _buildMuscleButtonsRow(BuildContext context) {
    final muscles = {
      'Chest': 'Chest',
      'Arms': ['Left Arm', 'Right Arm'],
      'Core': 'Abs',
      'Legs': ['Left Leg', 'Right Leg'],
      'Back': 'Back',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: muscles.entries.map((entry) {
          Color color;
          if (entry.value is String) {
            color = _getColorFromRank(_muscleRanks[entry.value] ?? '');
          } else {
            // Combine ranks if multiple muscles
            final ranks = (entry.value as List<String>)
                .map((muscle) => _muscleRanks[muscle] ?? '')
                .toList();
            // Just average by choosing the most dominant one (e.g., CHAMPION > GOLD > ...)
            color = _getColorFromRank(ranks.firstWhere((r) => r.isNotEmpty, orElse: () => ''));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withOpacity(0.2),
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: color),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => _highlightMuscle(context, entry.key),
              child: Text(entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ========== VISUAL EFFECTS ========== //

  void _highlightMuscle(BuildContext context, String muscle) {
    // Implement muscle highlight logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $muscle'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showMuscleDetails(BuildContext context, String muscle, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(muscle, style: TextStyle(color: color)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Current Rank:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color),
              ),
              child: Text(
                _getRankFromColor(color),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ========== SUPPORTING WIDGETS ========== //

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instantly Identify\nMuscles To Improve',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRankingItem(String muscle, String rank, bool isChecked) {
    Color rankColor;
    switch (rank.split(' ')[0]) {
      case 'CHAMPION':
        rankColor = Colors.green;
        break;
      case 'GOLD':
        rankColor = Colors.amber;
        break;
      case 'SILVER':
        rankColor = Colors.grey;
        break;
      case 'BRONZE':
        rankColor = Colors.brown;
        break;
      default:
        rankColor = Colors.blueGrey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (value) {},
            activeColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text(
            muscle,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: rankColor),
            ),
            child: Text(
              rank,
              style: TextStyle(
                color: rankColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  

  Widget _buildMuscleRankingsSection() {
    final muscleGroups = [
      'Chest',
      'Back',
      'Abs',
      'Left Arm',
      'Right Arm',
      'Left Leg',
      'Right Leg',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Muscle Rankings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final muscle in muscleGroups)
            _buildRankingItem(
              muscle,
              _muscleRanks[muscle] ?? 'Loading...',
              _muscleRanks[muscle]?.toUpperCase().contains('GOLD') ?? false,
            ),
        ],
      ),
    );
  }


  String _getRankFromColor(Color color) {
    if (color == Colors.amber) return 'Gold';
    if (color == Colors.grey) return 'Silver';
    if (color == Colors.green) return 'Champion';
    if (color == Colors.brown) return 'Bronze';
    return 'Bronze';
  }

  Color _getColorFromRank(String rank) {
    final upper = rank.toUpperCase();
    if (upper.contains('CHAMPION')) return Colors.green;
    if (upper.contains('GOLD')) return Colors.amber;
    if (upper.contains('SILVER')) return Colors.grey;
    if (upper.contains('BRONZE')) return Colors.brown;
    return Colors.blue;
  }
}

// ========== BODY PAINTER ========== //

class _BodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2 - 20),
          width: 120,
          height: 180,
        ),
        const Radius.circular(20),
      ),
      paint,
    );

    // Draw head
    canvas.drawCircle(
      Offset(size.width / 2, 40),
      20,
      paint,
    );

    // Draw arms
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(30, 100, 40, 120),
        const Radius.circular(20),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 70, 100, 40, 120),
        const Radius.circular(20),
      ),
      paint,
    );

    // Draw legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(60, 200, 50, 140),
        const Radius.circular(20),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 110, 200, 50, 140),
        const Radius.circular(20),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}