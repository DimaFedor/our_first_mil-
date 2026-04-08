import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

class CacheService {
  static const String _progressPrefix = 'cached_progress_';
  static const String _lastSyncKey = 'last_sync_timestamp';
  
  // Cache user progress locally
  Future<void> cacheProgress({
    required String userId,
    required String courseId,
    required Map<String, dynamic> progressData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_progressPrefix${userId}_$courseId';
      final jsonString = jsonEncode(progressData);
      await prefs.setString(key, jsonString);
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      AppLogger.error('Error caching progress', e);
    }
  }
  
  // Get cached progress
  Future<Map<String, dynamic>?> getCachedProgress({
    required String userId,
    required String courseId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_progressPrefix${userId}_$courseId';
      final jsonString = prefs.getString(key);
      
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      AppLogger.error('Error getting cached progress', e);
    }
    return null;
  }
  
  // Cache completed lessons list
  Future<void> cacheCompletedLessons({
    required String userId,
    required List<String> lessonIds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('completed_lessons_$userId', lessonIds);
    } catch (e) {
      AppLogger.error('Error caching completed lessons', e);
    }
  }
  
  // Get cached completed lessons
  Future<List<String>> getCachedCompletedLessons(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('completed_lessons_$userId') ?? [];
    } catch (e) {
      AppLogger.error('Error getting cached completed lessons', e);
      return [];
    }
  }
  
  // Cache user XP
  Future<void> cacheUserXP({
    required String userId,
    required int totalXP,
    required int currentStreak,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_xp_$userId', totalXP);
      await prefs.setInt('user_streak_$userId', currentStreak);
    } catch (e) {
      AppLogger.error('Error caching user XP', e);
    }
  }
  
  // Get cached user XP
  Future<Map<String, int>> getCachedUserXP(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'totalXP': prefs.getInt('user_xp_$userId') ?? 0,
        'currentStreak': prefs.getInt('user_streak_$userId') ?? 0,
      };
    } catch (e) {
      AppLogger.error('Error getting cached user XP', e);
      return {'totalXP': 0, 'currentStreak': 0};
    }
  }
  
  // Check if cache is stale (older than 24 hours)
  Future<bool> isCacheStale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = prefs.getInt(_lastSyncKey);
      
      if (lastSync == null) return true;
      
      final lastSyncDate = DateTime.fromMillisecondsSinceEpoch(lastSync);
      final now = DateTime.now();
      final difference = now.difference(lastSyncDate);
      
      return difference.inHours > 24;
    } catch (e) {
      return true;
    }
  }
  
  // Clear all cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_progressPrefix) || 
            key.startsWith('completed_lessons_') ||
            key.startsWith('user_xp_') ||
            key.startsWith('user_streak_')) {
          await prefs.remove(key);
        }
      }
      
      await prefs.remove(_lastSyncKey);
    } catch (e) {
      AppLogger.error('Error clearing cache', e);
    }
  }
  
  // Mark data as synced
  Future<void> markSynced() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      AppLogger.error('Error marking synced', e);
    }
  }
}
