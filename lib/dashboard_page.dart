import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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
                  // Chest (Upper/Lower)
                  _buildMuscleZone(context, 'Upper Chest', Colors.amber, 120, 40, 80, 50),
                  _buildMuscleZone(context, 'Lower Chest', Colors.amber[300]!, 120, 40, 80, 90),
                  
                  // Arms
                  _buildMuscleZone(context, 'Left Arm', Colors.blue, 40, 100, 50, 100),
                  _buildMuscleZone(context, 'Right Arm', Colors.blue, 40, 100, 190, 100),
                  
                  // Core
                  _buildMuscleZone(context, 'Abs', Colors.green, 100, 60, 90, 150),
                  
                  // Legs
                  _buildMuscleZone(context, 'Left Leg', Colors.purple, 50, 120, 80, 200),
                  _buildMuscleZone(context, 'Right Leg', Colors.purple, 50, 120, 150, 200),
                  
                  // Back (invisible but tappable)
                  _buildMuscleZone(context, 'Back', Colors.grey, 120, 180, 80, 100, visible: false),
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
    Color color,
    double width,
    double height,
    double left,
    double top, {
    bool visible = true,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => _showMuscleDetails(context, name, color),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: visible ? color.withOpacity(0.3) : Colors.transparent,
            border: visible ? Border.all(color: color, width: 2) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: visible
              ? Center(
                  child: Text(
                    name.split(' ').first,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  // ========== BUTTON ROW ========== //

  Widget _buildMuscleButtonsRow(BuildContext context) {
    final muscles = {
      'Chest': Colors.amber,
      'Arms': Colors.blue,
      'Core': Colors.green,
      'Legs': Colors.purple,
      'Back': Colors.brown,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: muscles.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: entry.value.withOpacity(0.2),
                foregroundColor: entry.value,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: entry.value),
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
                'Muscle Rankings ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.sentiment_satisfied_alt, color: Colors.amber),
            ],
          ),
          const SizedBox(height: 16),
          _buildRankingItem('Chest', 'GOLD', false),
          _buildRankingItem('Lower Chest', 'GOLD I', true),
          _buildRankingItem('Upper Chest', 'SILVER II', false),
          _buildRankingItem('Abs', 'CHAMPION', false),
          _buildRankingItem('Obliques', 'SILVER II', false),
          _buildRankingItem('Left Bicep', 'BRONZE', false),
          _buildRankingItem('Right Bicep', 'GOLD I', false),
          _buildRankingItem('Left Quad', 'GOLD', false),
          _buildRankingItem('Right Quad', 'GOLD', false),
        ],
      ),
    );
  }

  String _getRankFromColor(Color color) {
    if (color == Colors.amber) return 'GOLD';
    if (color == Colors.blue) return 'SILVER';
    if (color == Colors.green) return 'CHAMPION';
    if (color == Colors.purple) return 'GOLD II';
    return 'BRONZE';
  }
}

// ========== BODY PAINTER ========== //

class _BodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
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