import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/achievements/models/achievement_model.dart';

class EngagementNotificationService {
  EngagementNotificationService._();

  static final EngagementNotificationService instance =
      EngagementNotificationService._();

  static const int _dailyMotivationId = 7001;
  static const int _weeklyNudgeId = 7002;
  static const int _streakReminderId = 7003;
  static const int _instantStreakRiskId = 7004;
  static const int _instantStreakLostId = 7005;
  static const int _lessonWinId = 7010;
  static const int _achievementWinId = 7011;

  static const String _channelId = 'learning_engagement';
  static const String _channelName = 'Learning motivation';
  static const String _channelDescription =
      'Motivational reminders and progress notifications';

  static const String _streakRiskShownPrefix = 'streak_risk_shown';
  static const String _streakLostShownPrefix = 'streak_lost_shown';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Random _random = Random();

  bool _initialized = false;

  final List<String> _dailyMotivationTitles = const [
    'Tiny step, huge progress 💪',
    'Your future self says thanks 🚀',
    'Ready for one quick win today?',
    'You are closer than you think ✨',
  ];

  final List<String> _dailyMotivationBodies = const [
    'Do one lesson now and keep your momentum alive.',
    '15 minutes of practice today beats zero tomorrow.',
    'Open the app, solve one task, and keep the streak warm.',
    'Small, consistent sessions create big career results.',
  ];

  final List<String> _streakRiskBodies = const [
    'Your streak is at risk. One lesson today saves it.',
    'Don’t let your streak slip — you only need one quick task.',
    'You’re one tap away from protecting your progress.',
  ];

  final List<String> _streakLostBodies = const [
    'Your streak reset, but your progress is still yours. Start fresh today.',
    'No guilt, just comeback energy. Rebuild your streak now.',
    'A new streak starts with one lesson. You can do it.',
  ];

  final List<String> _weeklyBodies = const [
    'Set one mini-goal for this week and crush it.',
    'Pick one course and finish one lesson today.',
    'Your consistency this week can level you up fast.',
  ];

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('ic_notification');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> refreshForUser({
    required String userId,
    required int currentStreak,
    required int totalLessons,
    required int totalXP,
    required DateTime? lastActive,
  }) async {
    await initialize();

    await _scheduleDailyMotivation(
      totalLessons: totalLessons,
      totalXP: totalXP,
    );
    await _scheduleWeeklyNudge();
    await _scheduleStreakReminder(currentStreak: currentStreak);
    await _maybeShowStreakStateAlerts(
      userId: userId,
      currentStreak: currentStreak,
      lastActive: lastActive,
    );
  }

  Future<void> onLessonCompleted({
    required String userId,
    required int currentStreak,
    required int totalLessons,
    required int totalXP,
    required List<Achievement> unlockedAchievements,
  }) async {
    await initialize();

    await _showLessonWin(totalLessons: totalLessons, totalXP: totalXP);

    if (unlockedAchievements.isNotEmpty) {
      final totalAchievementXP = unlockedAchievements.fold<int>(
        0,
        (sum, achievement) => sum + achievement.xpReward,
      );
      final names = unlockedAchievements.map((e) => e.title).take(2).join(', ');
      final extraCount = unlockedAchievements.length > 2
          ? ' +${unlockedAchievements.length - 2} more'
          : '';
      await _show(
        id: _achievementWinId,
        title: 'Achievement unlocked 🏆',
        body: '$names$extraCount (+$totalAchievementXP XP)',
      );
    }

    await refreshForUser(
      userId: userId,
      currentStreak: currentStreak,
      totalLessons: totalLessons,
      totalXP: totalXP,
      lastActive: DateTime.now(),
    );
  }

  Future<void> _scheduleDailyMotivation({
    required int totalLessons,
    required int totalXP,
  }) async {
    final title = _pick(_dailyMotivationTitles);
    final progressBody = totalLessons > 0
        ? 'You already completed $totalLessons lessons and earned $totalXP XP.'
        : _pick(_dailyMotivationBodies);

    await _plugin.periodicallyShow(
      _dailyMotivationId,
      title,
      progressBody,
      RepeatInterval.daily,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> _scheduleWeeklyNudge() async {
    await _plugin.periodicallyShow(
      _weeklyNudgeId,
      'Weekly learning checkpoint 📈',
      _pick(_weeklyBodies),
      RepeatInterval.weekly,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> _scheduleStreakReminder({required int currentStreak}) async {
    if (currentStreak <= 0) {
      await _plugin.cancel(_streakReminderId);
      return;
    }

    await _plugin.periodicallyShow(
      _streakReminderId,
      'Keep your $currentStreak-day streak alive 🔥',
      _pick(_streakRiskBodies),
      RepeatInterval.daily,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> _maybeShowStreakStateAlerts({
    required String userId,
    required int currentStreak,
    required DateTime? lastActive,
  }) async {
    if (lastActive == null) return;

    final hoursSinceLastActive = DateTime.now().difference(lastActive).inHours;
    if (hoursSinceLastActive < 22) return;

    if (hoursSinceLastActive >= 48) {
      final key = '$_streakLostShownPrefix:$userId';
      if (await _canShowForKey(key, minHoursBetween: 20)) {
        await _show(
          id: _instantStreakLostId,
          title: 'Let’s restart strong 💫',
          body: _pick(_streakLostBodies),
        );
        await _markShownNow(key);
      }
      return;
    }

    if (currentStreak <= 0) return;
    final key = '$_streakRiskShownPrefix:$userId';
    if (await _canShowForKey(key, minHoursBetween: 12)) {
      await _show(
        id: _instantStreakRiskId,
        title: 'Your streak needs one lesson 🔥',
        body: _pick(_streakRiskBodies),
      );
      await _markShownNow(key);
    }
  }

  Future<void> _showLessonWin({
    required int totalLessons,
    required int totalXP,
  }) async {
    final celebrationBodies = [
      'Great work! You are now at $totalLessons lessons and $totalXP XP.',
      'Momentum unlocked. Keep it going — next lesson is waiting.',
      'Nice win! Consistency like this builds real skill.',
    ];
    await _show(
      id: _lessonWinId,
      title: 'Lesson complete ✅',
      body: _pick(celebrationBodies),
    );
  }

  Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _notificationDetails());
  }

  NotificationDetails _notificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  String _pick(List<String> items) => items[_random.nextInt(items.length)];

  Future<bool> _canShowForKey(
    String key, {
    required int minHoursBetween,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getInt(key);
    if (lastShown == null) return true;

    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastShown),
    );
    return elapsed.inHours >= minHoursBetween;
  }

  Future<void> _markShownNow(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);
  }
}
