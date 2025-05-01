import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<Map<String, String>> fetchBadgeTiers(String userId) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Map<String, String> badgeTiers = {};

  // Fetch workouts from correct path
  final workoutsSnapshot = await firestore
      .collection('workoutData')
      .doc(userId)
      .collection('workouts')
      .get();

  // Extract workout dates from metadata.date
  final List<DateTime> workoutDates = workoutsSnapshot.docs
      .where((doc) =>
          doc.data().containsKey('metadata') &&
          doc['metadata'] is Map &&
          (doc['metadata'] as Map).containsKey('date'))
      .map((doc) => (doc['metadata']['date'] as Timestamp).toDate())
      .toList();

  final Set<String> uniqueDays = workoutDates
      .map((d) => DateFormat('yyyy-MM-dd').format(d))
      .toSet();

  String getTier(int val, List<int> thresholds) {
    if (val >= thresholds[2]) return 'gold';
    if (val >= thresholds[1]) return 'silver';
    if (val >= thresholds[0]) return 'bronze';
    return 'none';
  }

  // --- Streak Starter ---
  final longestStreak = _calculateLongestStreak(workoutDates);
  badgeTiers['Streak Starter'] = getTier(longestStreak, [3, 5, 7]);

  // --- Weekly Warrior ---
  final DateTime now = DateTime.now();
  final DateTime weekStart = now.subtract(Duration(days: now.weekday % 7));
  final int weeklyCount =
      workoutDates.where((d) => d.isAfter(weekStart)).length;
  badgeTiers['Weekly Warrior'] = getTier(weeklyCount, [4, 5, 7]);

  // --- Calendar Collector ---
  badgeTiers['Calendar Collector'] = getTier(uniqueDays.length, [10, 20, 30]);

  // --- Champion Status ---
  final rankSnapshot = await firestore
      .collection('userRanks')
      .doc(userId)
      .collection('muscleGroups')
      .get();

  final int championCount = rankSnapshot.docs
      .where((doc) => doc['rank']?.toString().toLowerCase() == 'champion')
      .length;
  badgeTiers['Champion Status'] = getTier(championCount, [1, 3, 5]);

  // --- Leg Day Loyalist ---
  final legDays = <String>{};
  for (var doc in workoutsSnapshot.docs) {
    final data = doc.data();
    final metadata = data['metadata'];
    final liftData = data.containsKey('liftData') ? data['liftData'] : {};

    if (liftData.containsKey('Squat')) {
      final squatData = liftData['Squat'];
      if (squatData is Map<String, dynamic> &&
          (squatData['reps'] ?? 0) >= 5 &&
          metadata is Map &&
          metadata['date'] != null) {
        final date = (metadata['date'] as Timestamp).toDate();
        legDays.add(DateFormat('yyyy-MM-dd').format(date));
      }
    }
  }
  badgeTiers['Leg Day Loyalist'] = getTier(legDays.length, [3, 5, 7]);

  return badgeTiers;
}





int _calculateLongestStreak(List<DateTime> workoutDates) {
  final Set<String> uniqueDateStrings = workoutDates
      .map((d) => DateFormat('yyyy-MM-dd').format(d))
      .toSet();

  final List<DateTime> sortedDates = uniqueDateStrings
      .map((d) => DateFormat('yyyy-MM-dd').parse(d))
      .toList()
    ..sort(); // ascending order

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
    // If days are equal, skip (dupe)
  }

  longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
  return longestStreak;
}




Future<void> fetchAndUpdateBadgeTiers(String userId) async {
  final badgeTiers = await fetchBadgeTiers(userId);
  final badgeRef = FirebaseFirestore.instance
      .collection('badgeTiers')
      .doc(userId)
      .collection('badges');

  for (final entry in badgeTiers.entries) {
    await badgeRef.doc(entry.key).set({'tier': entry.value});
  }
}
