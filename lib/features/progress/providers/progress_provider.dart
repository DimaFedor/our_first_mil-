import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/engagement_notification_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../achievements/models/achievement_model.dart';
import '../../achievements/providers/achievement_provider.dart';

// User Progress Model
class UserProgress {
  final List<CourseProgress> courseProgress;
  final int totalXP;
  final int currentStreak;

  UserProgress({
    required this.courseProgress,
    required this.totalXP,
    required this.currentStreak,
  });
}

// Progress Model
class CourseProgress {
  final String courseId;
  final List<String> completedLessons;
  final int totalXP;
  final DateTime? lastUpdated;
  final DateTime? startedAt;

  CourseProgress({
    required this.courseId,
    required this.completedLessons,
    required this.totalXP,
    this.lastUpdated,
    this.startedAt,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      courseId: json['courseId'] ?? '',
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      totalXP: json['totalXP'] ?? 0,
      lastUpdated: (json['lastUpdated'] as Timestamp?)?.toDate(),
      startedAt: (json['startedAt'] as Timestamp?)?.toDate(),
    );
  }

  double getProgress(int totalLessons) {
    if (totalLessons == 0) return 0.0;
    return completedLessons.length / totalLessons;
  }
}

// Progress Provider
final progressServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

final engagementNotificationServiceProvider =
    Provider<EngagementNotificationService>((ref) {
      return EngagementNotificationService.instance;
    });

// User Progress Stream Provider with Offline Support
final userProgressProvider = StreamProvider.family<CourseProgress?, String>((
  ref,
  courseId,
) async* {
  final userId = ref.watch(currentUserUidProvider);
  if (userId == null) {
    yield null;
    return;
  }

  final useLocal = ref.watch(useLocalAuthProvider);
  final cacheService = ref.watch(cacheServiceProvider);

  // First yield cached data if available
  final cachedData = await cacheService.getCachedProgress(
    userId: userId,
    courseId: courseId,
  );

  if (cachedData != null) {
    yield CourseProgress.fromJson(cachedData);
  }

  // In local mode, only use cache
  if (useLocal) {
    if (cachedData == null) {
      yield null;
    }
    return;
  }

  // Then stream live data from Firestore and cache it
  final firestoreService = ref.watch(progressServiceProvider);
  await for (final snapshot
      in firestoreService
          .userProgressCollection(userId)
          .doc(courseId)
          .snapshots()) {
    if (!snapshot.exists) {
      yield null;
    } else {
      final data = snapshot.data() as Map<String, dynamic>;
      final progress = CourseProgress.fromJson(data);

      // Cache the data
      await cacheService.cacheProgress(
        userId: userId,
        courseId: courseId,
        progressData: data,
      );

      yield progress;
    }
  }
});

// All User Courses Progress Provider
final allUserProgressProvider = StreamProvider((ref) {
  final userId = ref.watch(currentUserUidProvider);
  if (userId == null) return Stream.value(<CourseProgress>[]);

  final useLocal = ref.watch(useLocalAuthProvider);

  // In local mode, return empty list (progress stored in cache)
  if (useLocal) {
    return Stream.value(<CourseProgress>[]);
  }

  final firestoreService = ref.watch(progressServiceProvider);

  return firestoreService.userProgressCollection(userId).snapshots().map((
    snapshot,
  ) {
    return snapshot.docs.map((doc) {
      return CourseProgress.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  });
});

// Progress Actions Provider
final progressActionsProvider = Provider<ProgressActions>((ref) {
  final firestoreService = ref.watch(progressServiceProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  final engagementNotifications = ref.watch(
    engagementNotificationServiceProvider,
  );
  final user = ref.watch(currentUserProvider);
  final achievementActions = ref.watch(achievementActionsProvider);
  return ProgressActions(
    firestoreService,
    cacheService,
    user?.uid,
    achievementActions,
    engagementNotifications,
  );
});

class ProgressActions {
  final FirestoreService _firestoreService;
  final CacheService _cacheService;
  final String? _userId;
  final AchievementActions _achievementActions;
  final EngagementNotificationService _engagementNotifications;

  ProgressActions(
    this._firestoreService,
    this._cacheService,
    this._userId,
    this._achievementActions,
    this._engagementNotifications,
  );

  Future<List<Achievement>> completeLesson({
    required String courseId,
    required String lessonId,
    required int xpEarned,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    // Update in Firestore
    await _firestoreService.updateProgress(
      userId: userId,
      courseId: courseId,
      lessonId: lessonId,
      xpEarned: xpEarned,
    );

    // Update streak
    await _firestoreService.updateStreak(userId);

    // Cache the updated progress
    final userData = await _firestoreService.getUserData(userId);
    final allProgress = await _firestoreService.getAllUserProgress(userId);

    final totalXP = userData?['totalXP'] as int? ?? 0;
    final currentStreak = userData?['currentStreak'] as int? ?? 0;
    int totalLessonsCount = 0;
    List<String> allCompletedLessons = [];
    bool hasJustCompletedLesson = false;
    for (var progress in allProgress) {
      final lessons = (progress['completedLessons'] as List? ?? [])
          .map((e) => e.toString())
          .toList();
      totalLessonsCount += lessons.length;
      allCompletedLessons.addAll(lessons);
      if (lessons.contains(lessonId)) {
        hasJustCompletedLesson = true;
      }
    }

    if (!hasJustCompletedLesson) {
      totalLessonsCount += 1;
      allCompletedLessons.add(lessonId);
    }

    final effectiveTotalXP = totalXP > 0 ? totalXP : xpEarned;

    // Cache XP and streak
    await _cacheService.cacheUserXP(
      userId: userId,
      totalXP: totalXP,
      currentStreak: currentStreak,
    );

    // Cache completed lessons
    await _cacheService.cacheCompletedLessons(
      userId: userId,
      lessonIds: allCompletedLessons,
    );

    // Mark as synced
    await _cacheService.markSynced();

    // Check for achievements and return newly unlocked ones
    final unlockedAchievements = await _achievementActions
        .checkAndUnlockAchievements(
          totalLessons: totalLessonsCount,
          currentStreak: currentStreak,
          totalXP: effectiveTotalXP,
        );

    await _engagementNotifications.onLessonCompleted(
      userId: userId,
      currentStreak: currentStreak,
      totalLessons: totalLessonsCount,
      totalXP: effectiveTotalXP,
      unlockedAchievements: unlockedAchievements,
    );

    return unlockedAchievements;
  }

  Future<bool> isLessonCompleted(String courseId, String lessonId) async {
    final userId = _userId;
    if (userId == null) return false;

    // Try cache first
    final cachedProgress = await _cacheService.getCachedProgress(
      userId: userId,
      courseId: courseId,
    );

    if (cachedProgress != null) {
      final lessons = (cachedProgress['completedLessons'] as List? ?? [])
          .map((e) => e.toString())
          .toList();
      return lessons.contains(lessonId);
    }

    // Fallback to Firestore
    final progress = await _firestoreService.getUserProgress(userId, courseId);
    if (progress == null) return false;

    final completedLessons = List<String>.from(
      progress['completedLessons'] ?? [],
    );
    return completedLessons.contains(lessonId);
  }
}
