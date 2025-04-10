import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
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
              //_buildHeaderSection(),
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
<<<<<<< Updated upstream
=======
<<<<<<< HEAD
                  _buildMuscleZone(
                    context,
                    'Chest',
                    Colors.amber,
                    120,
                    80,
                    80,
                    50,
                  ),
                  _buildMuscleZone(
                    context,
                    'Back',
                    Colors.brown,
                    120,
                    80,
                    80,
                    90,
                  ),

                  // Arms
                  _buildMuscleZone(
                    context,
                    'Left Arm',
                    Colors.blue,
                    40,
                    100,
                    50,
                    100,
                  ),
                  _buildMuscleZone(
                    context,
                    'Right Arm',
                    Colors.blue,
                    40,
                    100,
                    190,
                    100,
                  ),

                  // Core
                  _buildMuscleZone(
                    context,
                    'Abs',
                    Colors.green,
                    100,
                    60,
                    90,
                    150,
                  ),

                  // Legs
                  _buildMuscleZone(
                    context,
                    'Left Leg',
                    Colors.purple,
                    50,
                    120,
                    80,
=======
>>>>>>> Stashed changes
<<<<<<< Updated upstream
                  _buildMuscleZone(context, 'Back', Colors.brown, 120, 25, 80, 55),
                  _buildMuscleZone(context, 'Chest', Colors.amber, 120, 70, 80, 80),
                  
                  
                  // Arms
                  _buildMuscleZone(context, 'Left Arm', Colors.brown, 40, 100, 40, 70),
                  _buildMuscleZone(context, 'Right Arm', Colors.brown, 40, 100, 200, 70),
                  
                  // Core
                  _buildMuscleZone(context, 'Abs', Colors.grey, 65, 65, 110, 135),
                  
                  // Legs
                  _buildMuscleZone(context, 'Left Leg', Colors.amber, 50, 100, 80, 190),
                  _buildMuscleZone(context, 'Right Leg', Colors.amber, 50, 100, 150, 190),
                  
=======
                  _buildMuscleZone(
                    context,
                    'Back',
                    Colors.brown,
                    100,
                    100,
                    640,
                    70,
                  ),

                  _buildMuscleZone(
                    context,
                    'Chest',
                    Colors.amber,
                    100,
                    60,
                    640,
                    60,
                  ),

                  // Arms
                  _buildMuscleZone(
                    context,
                    'Left Arm',
                    Colors.blue,
                    40,
                    70,
                    600,
                    60,
                  ),
                  _buildMuscleZone(
                    context,
                    'Right Arm',
                    Colors.blue,
                    40,
                    70,
                    740,
                    60,
                  ),

                  //forarms
                  _buildMuscleZone(
                    context,
                    'Left Forearm',
                    Colors.red,
                    35,
                    50,
                    602,
                    135,
                  ),

                  _buildMuscleZone(
                    context,
                    'Right Forearm',
                    Colors.red,
                    35,
                    50,
                    742,
                    135,
                  ),

                  // Core
                  _buildMuscleZone(
                    context,
                    'Abs',
                    Colors.green,
                    100,
                    60,
                    640,
                    140,
                  ),

                  // Legs
                  _buildMuscleZone(
                    context,
                    'Left Upper Leg',
                    Colors.purple,
                    40,
                    60,
                    640,
<<<<<<< Updated upstream
=======
>>>>>>> 05a67f9febe8a9488b234af6f1732efeaa1da2c4
>>>>>>> Stashed changes
                    200,
                  ),
                  _buildMuscleZone(
                    context,
<<<<<<< Updated upstream
=======
<<<<<<< HEAD
                    'Right Leg',
                    Colors.purple,
                    50,
                    120,
                    150,
                    200,
                  ),
=======
>>>>>>> Stashed changes
                    'Right Upper Leg',
                    Colors.purple,
                    40,
                    60,
                    700,
                    200,
                  ),

                  //lower legs
                  _buildMuscleZone(
                    context,
                    'Left Calf',
                    Colors.orange,
                    40,
                    60,
                    640,
                    260,
                  ),

                  _buildMuscleZone(
                    context,
                    'Right Calf',
                    Colors.orange,
                    40,
                    60,
                    700,
                    260,
                  ),
>>>>>>> Stashed changes
<<<<<<< Updated upstream
=======
>>>>>>> 05a67f9febe8a9488b234af6f1732efeaa1da2c4
>>>>>>> Stashed changes
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
          child:
              visible
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
<<<<<<< Updated upstream
      'Arms': Colors.brown,
      'Core': Colors.grey,
      'Legs': Colors.amber,
=======
      'Upper Arms': Colors.blue,
      'Lower Arms': Colors.red,
      'Core': Colors.green,
      'Upper Legs': Colors.purple,
      'Lower Legs': Colors.orange,
>>>>>>> Stashed changes
      'Back': Colors.brown,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            muscles.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: entry.value.withValues(alpha: (0.1 * 255)),
                    foregroundColor: entry.value,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: entry.value),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
      builder:
          (context) => AlertDialog(
            title: Text(muscle, style: TextStyle(color: color)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Current Rank:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: (0.1 * 255)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    _getRankFromColor(color),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
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

<<<<<<< Updated upstream
  // Widget _buildHeaderSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Instantly Identify\nMuscles To Improve',
  //         style: TextStyle(
  //           fontSize: 24,
  //           fontWeight: FontWeight.bold,
  //           height: 1.2,
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //     ],
  //   );
  // }
=======
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instantly Identify Muscles To Improve',
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
>>>>>>> Stashed changes

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
          Text(muscle, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: (0.2 * 255)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: rankColor),
            ),
            child: Text(
              rank,
              style: TextStyle(color: rankColor, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRankingItem('Chest', 'GOLD', false),
          _buildRankingItem('Back', 'BRONZE', true),
          _buildRankingItem('Abs', 'SILVER', false),
          _buildRankingItem('Biceps', 'BRONZE', false),
          _buildRankingItem('Quads', 'GOLD', false),
        ],
      ),
    );
  }

  String _getRankFromColor(Color color) {
    if (color == Colors.amber) return 'GOLD';
    if (color == Colors.blue) return 'SILVER';
    if (color == Colors.green) return 'CHAMPION';
    if (color == Colors.brown) return 'Bronze';
    if (color == Colors.amber) return 'GOLD I';
    return 'BRONZE';
  }
}

//========== BODY PAINTER ========== //

class _BodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
<<<<<<< Updated upstream

=======
<<<<<<< HEAD
    // variables for use
    final paint =
        Paint()
          ..color = Colors.grey[200]!
          ..style = PaintingStyle.fill;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final torsoWidth = 100.0;
    final torsoHeight = 160.0;
    final headRadius = 30.0;
    final armWidth = 35.0;
    final armHeight = 135.0;
    final legWidth = 40.0;
    final legHeight = 120.0;
=======

>>>>>>> 05a67f9febe8a9488b234af6f1732efeaa1da2c4
>>>>>>> Stashed changes

    // Draw torso
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
<<<<<<< Updated upstream

=======
<<<<<<< HEAD
          center: Offset(centerX, centerY - 20),
          width: torsoWidth,
          height: torsoHeight,
=======

>>>>>>> 05a67f9febe8a9488b234af6f1732efeaa1da2c4
>>>>>>> Stashed changes
        ),
        const Radius.circular(20),
      ),
      paint,
    );

<<<<<<< Updated upstream
=======
<<<<<<< HEAD
    // Draw head
    canvas.drawCircle(Offset(centerX, 20), headRadius, paint);

=======
>>>>>>> 05a67f9febe8a9488b234af6f1732efeaa1da2c4
>>>>>>> Stashed changes
    // Draw arms
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX - (torsoWidth / 2) - armWidth - 2,
          centerY - 20 - (torsoHeight / 2) + 8,
          armWidth,
          armHeight,
        ),
        const Radius.circular(20),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX + (torsoWidth / 2) + 2,
          centerY - 20 - (torsoHeight / 2) + 8,
          armWidth,
          armHeight,
        ),
        const Radius.circular(20),
      ),
      paint,
    );

    // Draw legs
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - (torsoWidth / 2), 210, legWidth, legHeight),
        const Radius.circular(10),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          centerX + (torsoWidth / 2) - legWidth,
          210,
          legWidth,
          legHeight,
        ),
        const Radius.circular(10),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

<<<<<<< Updated upstream
=======
<<<<<<< HEAD

=======
>>>>>>> 05a67f9febe8a9488b234af6f1732efeaa1da2c4
>>>>>>> Stashed changes
