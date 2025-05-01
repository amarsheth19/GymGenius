import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_genius/badge_service.dart';
import 'firebase_options.dart';
import 'dashboard_page.dart';
import 'record_page.dart';
import 'suggestions_page.dart';


import 'profile_page.dart';
import 'progress_page.dart';

// add more themes
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: const Color.fromARGB(255, 245, 245, 245),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    iconTheme: IconThemeData(color: Colors.black),
  ),
  cardColor: Colors.white,
  cardTheme: CardTheme(
    color: Colors.white,
    shadowColor: Colors.grey.withOpacity(0.1),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.black),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    unselectedItemColor: Colors.grey,
    selectedItemColor: Colors.blueAccent,
    backgroundColor: Color.fromARGB(255, 245, 245, 245),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(backgroundColor: Colors.black87),
);

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> initializeMuscleRanksIfNeeded(String userId) async {
  final firestore = FirebaseFirestore.instance;
  final userRanksRef = firestore.collection('userRanks').doc(userId);
  final muscleGroups = [
    'Chest', 'Back', 'Abs',
    'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg',
  ];

  for (String muscle in muscleGroups) {
    final docRef = userRanksRef.collection('muscleGroups').doc(muscle);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({'rank': 'BRONZE'});
    }
  }
}

Future<void> syncBadgesOnStartup(String userId) async {
  final badgeTiers = await fetchBadgeTiers(userId);
  await FirebaseFirestore.instance
      .collection('userBadges')
      .doc(userId)
      .set(badgeTiers, SetOptions(merge: true));
}

Future<void> syncUserRanksOnStartup(String userId) async {
  final firestore = FirebaseFirestore.instance;
  final workoutsSnapshot = await firestore
      .collection('workoutData')
      .doc(userId)
      .collection('workouts')
      .get();

  final Map<String, double> bestScores = {
    'Left Arm': 0,
    'Right Arm': 0,
    'Chest': 0,
    'Back': 0,
    'Left Leg': 0,
    'Right Leg': 0,
    'Abs': 0,
  };

  final Map<String, List<String>> exerciseToMuscles = {
    'Bench Press': ['Left Arm', 'Right Arm', 'Chest', 'Abs'],
    'Deadlift': ['Back', 'Abs'],
    'Squat': ['Left Leg', 'Right Leg', 'Abs'],
  };

  for (var doc in workoutsSnapshot.docs) {
    final data = doc.data();
    if (data.containsKey('liftData')) {
      final liftData = data['liftData'] as Map<String, dynamic>;
      for (var exercise in liftData.entries) {
        final name = exercise.key;
        final info = exercise.value;
        if (info is Map<String, dynamic>) {
          final reps = info['reps'] ?? 0;
          final weight = info['weight'] ?? 0.0;
          if (reps is int && weight is num) {
            final score = reps * weight;
            final muscles = exerciseToMuscles[name] ?? [];
            for (var muscle in muscles) {
              final currentBest = bestScores[muscle] ?? 0;
              if (score > currentBest) {
                bestScores[muscle] = score.toDouble();
              }
            }
          }
        }
      }
    }
  }

  // Assign ranks based on thresholds
  String getRank(double score) {
    if (score >= 300) return 'CHAMPION';
    if (score >= 200) return 'GOLD';
    if (score >= 100) return 'SILVER';
    if (score > 0) return 'BRONZE';
    return 'UNRANKED';
  }

  final userRanksRef = firestore.collection('userRanks').doc(userId);
  for (var muscle in bestScores.entries) {
    await userRanksRef.collection('muscleGroups').doc(muscle.key).set({
      'rank': getRank(muscle.value),
      'score': muscle.value,
    }, SetOptions(merge: true));
  }
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          themeMode: currentTheme,
          darkTheme: darkTheme,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Call once per login session
          initializeMuscleRanksIfNeeded(user.uid);
        }

        return const MainScreen(); // Continue to main app
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const SuggestionsPage(),
    const RecordPage(),
    const ProgressPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        syncBadgesOnStartup(user.uid);
        syncUserRanksOnStartup(user.uid); // <-- add this
      }
    });
  }


  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Suggestions'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Record'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
