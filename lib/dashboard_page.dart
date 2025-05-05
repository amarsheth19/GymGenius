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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Muscle Map'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
              children: [
                const SizedBox(height: 24),
                _buildInteractiveBodyGraph(context),
                const SizedBox(height: 24),
                _buildMuscleRankingsSection(context),
              ],
            ),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
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
                    top: 5,
                    left: 143,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  _buildMuscleZone(context, 'Back', 185, 25, 70, 55),
                  _buildMuscleZone(context, 'Chest', 105, 70, 110, 80),
                  _buildMuscleZone(context, 'Left Arm', 40, 90, 70, 80),
                  _buildMuscleZone(context, 'Right Arm', 40, 90, 215, 80),
                  _buildMuscleZone(context, 'Abs', 55, 46, 135, 147),
                  _buildMuscleZone(context, 'Left Leg', 44, 100, 110, 190),
                  _buildMuscleZone(context, 'Right Leg', 44, 100, 170, 190),
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

    if (name == 'Chest') {
      return Positioned(
        left: left,
        top: top,
        child: GestureDetector(
          onTap: () => _showMuscleDetails(context, name, color),
          child: SizedBox(
            width: width,
            height: height,
            child: CustomPaint(
              painter: TrapezoidPainter(color),
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
        ),
      );
    }

    // Default rectangular zone for other muscles
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
            final ranks = (entry.value as List<String>)
                .map((muscle) => _muscleRanks[muscle] ?? '')
                .toList();
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

  void _highlightMuscle(BuildContext context, String muscle) {
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

  Widget _buildMuscleRankingsSection(BuildContext context) {
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
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
              context,
              muscle,
              _muscleRanks[muscle] ?? 'Loading...',
            ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(BuildContext context, String muscle, String rank) {
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
          Text(
            muscle,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
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

  Color _getColorFromRank(String rank) {
    switch (rank.toUpperCase()) {
      case 'CHAMPION':
        return Colors.green;
      case 'GOLD':
        return Colors.amber;
      case 'SILVER':
        return Colors.grey;
      case 'BRONZE':
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }

  String _getRankFromColor(Color color) {
    if (color == Colors.green) return 'CHAMPION';
    if (color == Colors.amber) return 'GOLD';
    if (color == Colors.grey) return 'SILVER';
    if (color == Colors.brown) return 'BRONZE';
    return 'Unknown';
  }
}

// Dummy painter for the body outline
class _BodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // You can add a custom body outline here if you want
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TrapezoidPainter extends CustomPainter {
  final Color color;
  TrapezoidPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Top is long, bottom is short
    final path = Path()
      ..moveTo(0, 0) // top left (wide)
      ..lineTo(size.width, 0) // top right (wide)
      ..lineTo(size.width * 0.75, size.height) // bottom right (narrow)
      ..lineTo(size.width * 0.25, size.height) // bottom left (narrow)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}