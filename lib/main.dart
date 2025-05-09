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

final ThemeData redEnergyTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.redAccent,
  scaffoldBackgroundColor: const Color(0xFFFFF5F5),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.redAccent,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    iconTheme: IconThemeData(color: Colors.redAccent),
  ),
  cardColor: Colors.white,
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: Colors.redAccent.withOpacity(0.2),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.redAccent),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.redAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Colors.redAccent,
    unselectedItemColor: Colors.grey,
    backgroundColor: Color(0xFFFFF5F5),
  ),
);

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

final ThemeData premiumSteelGrayTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF1F1F1F),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F1F1F),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Color(0xFFD4AF37), // Gold Accent
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
    iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
  ),
  cardColor: const Color(0xFF1F1F1F),
  cardTheme: CardTheme(
    color: const Color(0xFF1F1F1F),
    elevation: 6,
    shadowColor: Colors.black.withOpacity(0.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(color: Color(0xFFD4AF37)), // Gold title
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFD4AF37),
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Color(0xFFD4AF37),
    unselectedItemColor: Colors.grey,
    backgroundColor: Color(0xFF1F1F1F),
  ),
);

final ThemeData freshGreenTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.green,
  scaffoldBackgroundColor: const Color(0xFFF0FFF0),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    iconTheme: IconThemeData(color: Colors.green),
  ),
  cardColor: Colors.white,
  cardTheme: CardTheme(
    color: Colors.white,
    shadowColor: Colors.green.withOpacity(0.1),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.green),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Colors.green,
    unselectedItemColor: Colors.grey,
    backgroundColor: Color(0xFFF0FFF0),
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
    'Chest',
    'Back',
    'Abs',
    'Left Arm',
    'Right Arm',
    'Left Leg',
    'Right Leg',
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
  final firestore = FirebaseFirestore.instance;

  for (final entry in badgeTiers.entries) {
    final badgeName = entry.key;
    final tier = entry.value;

    await firestore
        .collection('badgeTiers')
        .doc(userId)
        .collection('badges')
        .doc(badgeName)
        .set({'tier': tier}, SetOptions(merge: true));
  }
}

Future<Map<String, Map<String, dynamic>>> fetchUserRanks(String userId) async {
  final ranksSnapshot = await FirebaseFirestore.instance
      .collection('userRanks')
      .doc(userId)
      .collection('muscleGroups')
      .get();

  return {
    for (var doc in ranksSnapshot.docs)
      doc.id: {
        'rank': doc['rank'],
        'score': doc['score'],
      }
  };
}

Future<void> syncUserRanksOnStartup(String userId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final muscleRanks = await fetchUserRanks(user.uid);
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
