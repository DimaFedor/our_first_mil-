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
  Future<void> createUserDocument(User user, {String? displayName}) async {
    final userDoc = usersCollection.doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName ?? user.displayName ?? 'User',
        'photoURL': user.photoURL,
        'totalXP': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });
    }
  }

  // Update User Progress
  Future<void> updateProgress({
    required String userId,
    required String courseId,
    required String lessonId,
    required int xpEarned,
  }) async {
    AppLogger.debug('Updating progress: user=$userId, course=$courseId, lesson=$lessonId');
    
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

    // Update user's total XP
    await usersCollection.doc(userId).update({
      'totalXP': FieldValue.increment(xpEarned),
      'lastActive': FieldValue.serverTimestamp(),
    });
    
    AppLogger.success('Progress saved: +$xpEarned XP');
  }

  // Update Streak
  Future<void> updateStreak(String userId) async {
    final userDoc = usersCollection.doc(userId);
    final snapshot = await userDoc.get();
    final data = snapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      final lastActive = (data['lastActive'] as Timestamp?)?.toDate();
      final now = DateTime.now();
      final currentStreak = data['currentStreak'] as int? ?? 0;
      final longestStreak = data['longestStreak'] as int? ?? 0;

      int newStreak = currentStreak;

      if (lastActive != null) {
        final difference = now.difference(lastActive).inDays;
        if (difference == 1) {
          newStreak = currentStreak + 1;
        } else if (difference > 1) {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }

      await userDoc.update({
        'currentStreak': newStreak,
        'longestStreak': newStreak > longestStreak ? newStreak : longestStreak,
        'lastActive': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get User Progress for Course
  Future<Map<String, dynamic>?> getUserProgress(
      String userId, String courseId) async {
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
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
