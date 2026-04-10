import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/achievement_model.dart';

final achievementsProvider = StreamProvider<List<UserAchievement>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('users')
      .doc(user.uid)
      .collection('achievements')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map(
              (doc) => UserAchievement.fromJson(
                doc.data(),
                fallbackAchievementId: doc.id,
              ),
            )
            .toList();
      });
});

final achievementActionsProvider = Provider<AchievementActions>((ref) {
  final user = ref.watch(currentUserProvider);
  return AchievementActions(user?.uid);
});

class AchievementActions {
  final String? _userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AchievementActions(this._userId);

  Future<List<Achievement>> checkAndUnlockAchievements({
    required int totalLessons,
    required int currentStreak,
    required int totalXP,
  }) async {
    if (_userId == null) return [];

    final newlyUnlocked = <Achievement>[];

    final allAchievements = Achievement.getAllAchievements();
    final unlockedSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('achievements')
        .get();

    final unlockedIds = unlockedSnapshot.docs.map((d) => d.id).toSet();

    for (final achievement in allAchievements) {
      if (unlockedIds.contains(achievement.id)) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.lessonComplete:
          shouldUnlock = totalLessons >= achievement.requirement;
          break;
        case AchievementType.streak:
          shouldUnlock = currentStreak >= achievement.requirement;
          break;
        case AchievementType.xp:
          shouldUnlock = totalXP >= achievement.requirement;
          break;
        default:
          break;
      }

      if (shouldUnlock) {
        await _unlockAchievement(achievement);
        newlyUnlocked.add(achievement);
      }
    }

    return newlyUnlocked;
  }

  Future<void> _unlockAchievement(Achievement achievement) async {
    if (_userId == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('achievements')
        .doc(achievement.id)
        .set({
          'achievementId': achievement.id,
          'unlockedAt': DateTime.now().toIso8601String(),
        });

    // Award XP
    await _firestore.collection('users').doc(_userId).set({
      'totalXP': FieldValue.increment(achievement.xpReward),
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
