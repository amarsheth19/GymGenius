import 'package:cloud_firestore/cloud_firestore.dart';

int getPointsForTier(String tier) {
  switch (tier.toLowerCase()) {
    case 'bronze':
      return 0;
    case 'silver':
      return 15;
    case 'gold':
      return 30;
    case 'champion':
      return 45;
    default:
      return 0;
  }
}

Future<int> calculateUserPoints(String userId) async {
  final firestore = FirebaseFirestore.instance;
  int totalPoints = 0;

  final badgeSnapshot = await firestore
      .collection('badgeTiers')
      .doc(userId)
      .collection('badges')
      .get();

  for (var doc in badgeSnapshot.docs) {
    totalPoints += getPointsForTier(doc['tier']);
  }

  final rankSnapshot = await firestore
      .collection('userRanks')
      .doc(userId)
      .collection('muscleGroups')
      .get();

  for (var doc in rankSnapshot.docs) {
    totalPoints += getPointsForTier(doc['rank']);
  }

  return totalPoints;
}

Future<void> updateUserTier(String userId, int points) async {
  String tier = 'bronze';
  if (points >= 300) {
    tier = 'champion';
  } else if (points >= 200) {
    tier = 'gold';
  } else if (points >= 100) {
    tier = 'silver';
  }

  await FirebaseFirestore.instance
      .collection('userTiers')
      .doc(userId)
      .set({'tier': tier, 'points': points});
}
