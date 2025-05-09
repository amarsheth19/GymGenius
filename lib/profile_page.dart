import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'main.dart'; // for themeNotifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'badge_service.dart';
import 'tier_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  int _totalWorkouts = 0;
  int _longestStreak = 0;
  String _tier = 'bronze';
  int _points = 0;
  bool _loading = true;

  final Map<String, int> _tierRequirements = {
    'bronze': 0,
    'silver': 100,
    'gold': 200,
    'champion': 300,
  };

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _fetchProfileStats();
    }
  }

  Future<void> _fetchProfileStats() async {
    final userId = user!.uid;
    // Fetch workouts from workoutData (for streaks) and userWorkouts (for total)
    final workoutDataSnap = await FirebaseFirestore.instance
        .collection('workoutData')
        .doc(userId)
        .collection('workouts')
        .get();

    // Extract workout dates for streak calculation
    final List<DateTime> workoutDates = workoutDataSnap.docs
        .where((doc) =>
            doc.data().containsKey('metadata') &&
            doc['metadata'] is Map &&
            (doc['metadata'] as Map).containsKey('date'))
        .map((doc) => (doc['metadata']['date'] as Timestamp).toDate())
        .toList();

    // Total workouts (from userWorkouts)
    final userWorkoutsSnap = await FirebaseFirestore.instance
        .collection('userWorkouts')
        .doc(userId)
        .collection('workouts')
        .get();
    final totalWorkouts = userWorkoutsSnap.docs.length;

    // Longest streak
    int longestStreak = _calculateLongestStreak(workoutDates);

    // Fetch tier and points
    final tierDoc = await FirebaseFirestore.instance
        .collection('userTiers')
        .doc(userId)
        .get();
    String tier = tierDoc.exists ? (tierDoc['tier'] ?? 'bronze') : 'bronze';
    int points = tierDoc.exists ? (tierDoc['points'] ?? 0) : 0;

    setState(() {
      _totalWorkouts = totalWorkouts;
      _longestStreak = longestStreak;
      _tier = tier;
      _points = points;
      _loading = false;
    });
  }

  int _calculateLongestStreak(List<DateTime> workoutDates) {
    final Set<String> uniqueDateStrings = workoutDates
        .map((d) => DateUtils.dateOnly(d).toIso8601String())
        .toSet();

    final List<DateTime> sortedDates = uniqueDateStrings
        .map((d) => DateTime.parse(d))
        .toList()
      ..sort();

    int longestStreak = 0;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
      } else if (diff > 1) {
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
        currentStreak = 1;
      }
    }
    longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
    return longestStreak;
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
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

  Widget _buildTierProgressCard() {
    final tiers = _tierRequirements.keys.toList();
    final currentIndex = tiers.indexOf(_tier);
    final nextTier = currentIndex < tiers.length - 1 ? tiers[currentIndex + 1] : null;

    final currentThreshold = _tierRequirements[_tier]!;
    final nextThreshold = nextTier != null ? _tierRequirements[nextTier]! : currentThreshold;

    final progressPoints = _points - currentThreshold;
    final requiredPoints = nextTier != null ? nextThreshold - currentThreshold : 0;
    final progressFraction = nextTier != null && requiredPoints > 0
        ? progressPoints / requiredPoints
        : 1.0;

    return Card(
      color: const Color(0xFF292B45),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 22,
            child: Text(
              _tier[0].toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _getTierColor(_tier),
              ),
            ),
          ),
          title: const Text(
            "Tier Progress",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Current Tier: ${_tier[0].toUpperCase()}${_tier.substring(1)}",
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              if (nextTier != null)
                Text(
                  "Progress to ${nextTier[0].toUpperCase()}${nextTier.substring(1)}: $progressPoints / $requiredPoints points",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                )
              else
                const Text(
                  "You've reached the highest tier!",
                  style: TextStyle(color: Colors.green, fontSize: 13),
                ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressFraction.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(_getTierColor(_tier)),
                minHeight: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF181C2F), Color(0xFF2196F3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Please sign in to view your profile", 
                  style: TextStyle(color: Colors.white, fontSize: 18)
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          if (user == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.login, color: Colors.black),
                      SizedBox(width: 4),
                      Text(
                        "Log in",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (user != null) // Show logout button if logged in
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, color: Theme.of(context).appBarTheme.titleTextStyle?.color),
                      SizedBox(width: 4),
                      Text(
                        "Log out",
                        style: TextStyle(
                          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF181C2F), Color(0xFF2196F3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Text(
                      "Welcome, ${user!.displayName ?? "User"}!",
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            color: const Color(0xFF292B45),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(Icons.fitness_center, color: Colors.blue, size: 32),
                              title: const Text("Completed Workouts", style: TextStyle(color: Colors.white)),
                              trailing: Text(
                                '$_totalWorkouts',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Card(
                            color: const Color(0xFF292B45),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(Icons.whatshot, color: Colors.redAccent, size: 32),
                              title: const Text("Longest Streak", style: TextStyle(color: Colors.white)),
                              trailing: Text(
                                '$_longestStreak',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTierProgressCard(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Column(
                        children: [
                          const Text(
                            "App Theme",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: themeNotifier,
                            builder: (context, currentMode, _) {
                              return DropdownButton<ThemeMode>(
                                dropdownColor: const Color(0xFF23243B),
                                value: currentMode,
                                onChanged: (ThemeMode? newMode) {
                                  if (newMode != null) {
                                    themeNotifier.value = newMode;
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: ThemeMode.system,
                                    child: Text("System Default", style: TextStyle(color: Colors.white)),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.light,
                                    child: Text("Light", style: TextStyle(color: Colors.white)),
                                  ),
                                  DropdownMenuItem(
                                    value: ThemeMode.dark,
                                    child: Text("Dark", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
