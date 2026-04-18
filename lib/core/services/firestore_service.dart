import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logger_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users Collection
  CollectionReference get usersCollection => _firestore.collection('users');

  // Progress Collection
  CollectionReference userProgressCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('progress');

  // Courses Collection
  CollectionReference get coursesCollection => _firestore.collection('courses');

  // Get or Create User Document
  Future<void> createUserDocument(
    User user, {
    String? displayName,
    String skillLevel = 'beginner',
    String preferredLanguage = 'python',
    String authMethod = 'email',
    String bio = '',
    int dailyGoalMinutes = 20,
  }) async {
    final userDoc = usersCollection.doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName ?? user.displayName ?? 'User',
        'photoURL': user.photoURL,
        'skillLevel': skillLevel,
        'preferredLanguage': preferredLanguage,
        'authMethod': authMethod,
        'bio': bio,
        'dailyGoalMinutes': dailyGoalMinutes,
        'onboardingCompleted': true,
        'totalXP': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    required String email,
    required String skillLevel,
    required String preferredLanguage,
    String? photoURL,
    String bio = '',
    int dailyGoalMinutes = 20,
  }) async {
    final payload = <String, dynamic>{
      'uid': userId,
      'displayName': displayName,
      'email': email,
      'skillLevel': skillLevel,
      'preferredLanguage': preferredLanguage,
      'bio': bio,
      'dailyGoalMinutes': dailyGoalMinutes,
      'lastProfileUpdate': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    };
    if (photoURL != null) {
      payload['photoURL'] = photoURL;
    }
    await usersCollection.doc(userId).set(payload, SetOptions(merge: true));
  }

  // Update User Progress
  Future<void> updateProgress({
    required String userId,
    required String courseId,
    required String lessonId,
    required int xpEarned,
  }) async {
    AppLogger.debug(
      'Updating progress: user=$userId, course=$courseId, lesson=$lessonId',
    );

    final progressDoc = userProgressCollection(userId).doc(courseId);
    final progressSnapshot = await progressDoc.get();

    if (progressSnapshot.exists) {
      await progressDoc.update({
        'completedLessons': FieldValue.arrayUnion([lessonId]),
        'totalXP': FieldValue.increment(xpEarned),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } else {
      await progressDoc.set({
        'courseId': courseId,
        'completedLessons': [lessonId],
        'totalXP': xpEarned,
        'startedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    // Update user's total XP (merge to avoid failure if user doc doesn't exist yet)
    await usersCollection.doc(userId).set({
      'uid': userId,
      'totalXP': FieldValue.increment(xpEarned),
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    AppLogger.success('Progress saved: +$xpEarned XP');
  }

  // Update Streak
  Future<void> updateStreak(String userId) async {
    final userDoc = usersCollection.doc(userId);
    final snapshot = await userDoc.get();
    final data = snapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      await userDoc.set({
        'uid': userId,
        'currentStreak': 1,
        'longestStreak': 1,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    final lastActive = (data['lastActive'] as Timestamp?)?.toDate();
    final now = DateTime.now();
    final currentStreak = data['currentStreak'] as int? ?? 0;
    final longestStreak = data['longestStreak'] as int? ?? 0;
    final rewardWalletRaw = data['xpRewards'];
    final rewardWallet = rewardWalletRaw is Map
        ? Map<String, dynamic>.from(rewardWalletRaw)
        : <String, dynamic>{};
    final streakShields = (rewardWallet['streakShields'] as num?)?.toInt() ?? 0;

    int newStreak = currentStreak;
    var consumedStreakShield = false;

    if (lastActive != null) {
      final difference = now.difference(lastActive).inDays;
      if (difference == 1) {
        newStreak = currentStreak + 1;
      } else if (difference > 1) {
        if (streakShields > 0 && difference <= 2) {
          consumedStreakShield = true;
          newStreak = currentStreak + 1;
          rewardWallet['streakShields'] = streakShields - 1;
        } else {
          newStreak = 1;
        }
      }
    } else {
      newStreak = 1;
    }

    final payload = <String, dynamic>{
      'uid': userId,
      'currentStreak': newStreak,
      'longestStreak': newStreak > longestStreak ? newStreak : longestStreak,
      'lastActive': FieldValue.serverTimestamp(),
    };
    if (consumedStreakShield) {
      payload['xpRewards'] = rewardWallet;
    }

    await userDoc.set(payload, SetOptions(merge: true));
  }

  // Get User Progress for Course
  Future<Map<String, dynamic>?> getUserProgress(
    String userId,
    String courseId,
  ) async {
    final doc = await userProgressCollection(userId).doc(courseId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Get User Data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await usersCollection.doc(userId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Get All User Progress
  Future<List<Map<String, dynamic>>> getAllUserProgress(String userId) async {
    final snapshot = await userProgressCollection(userId).get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
