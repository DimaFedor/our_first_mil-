import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/course_localization_service.dart';
import '../../achievements/models/achievement_model.dart';
import '../../achievements/providers/achievement_provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../courses/models/course_model.dart';
import '../../progress/providers/progress_provider.dart';
import '../../progress/services/xp_system.dart';
import '../models/learning_journey_models.dart';
import '../providers/learning_journey_provider.dart';

class LearningJourneyScreen extends ConsumerStatefulWidget {
  const LearningJourneyScreen({super.key});

  @override
  ConsumerState<LearningJourneyScreen> createState() =>
      _LearningJourneyScreenState();
}

class _LearningJourneyScreenState extends ConsumerState<LearningJourneyScreen> {
  String? _hoveredNodeId;

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserUidProvider);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final l10n = AppLocalizations.of(context);
    final isUkr = _isUkrainianLocale(context);

    if (userId == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              _tr(
                context,
                en: 'Sign in to open your journey.',
                uk: 'Увійдіть, щоб відкрити вашу навчальну подорож.',
              ),
              style: TextStyle(color: onSurface),
            ),
          ),
        ),
      );
    }

    final userDataAsync = ref.watch(userDataProvider(userId));
    final progressAsync = ref.watch(allUserProgressProvider);
    final coursesAsync = ref.watch(localizedCoursesProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final levelInfoAsync = ref.watch(levelInfoProvider);
    final portfolioEntriesAsync = ref.watch(portfolioEntriesProvider(userId));
    final onboardingAsync = ref.watch(
      learningJourneyOnboardingProvider(userId),
    );

    final userData = userDataAsync.valueOrNull;
    final levelInfo =
        levelInfoAsync.valueOrNull ??
        XPSystem.getLevelInfo(userData?.totalXP ?? 0);
    final progress = progressAsync.valueOrNull ?? const <CourseProgress>[];
    final courses = coursesAsync.valueOrNull ?? const <Course>[];
    final achievements =
        achievementsAsync.valueOrNull ?? const <UserAchievement>[];
    final portfolioEntries =
        portfolioEntriesAsync.valueOrNull ?? const <PortfolioEntry>[];
    final onboardingDone = onboardingAsync.valueOrNull ?? false;

    final hasCriticalError =
        coursesAsync.hasError ||
        progressAsync.hasError ||
        userDataAsync.hasError;
    final isLoadingCore = coursesAsync.isLoading || progressAsync.isLoading;

    if (hasCriticalError && courses.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: _backgroundDecoration(isDarkTheme),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: onSurface, size: 34),
                    const SizedBox(height: 12),
                    Text(
                      _tr(
                        context,
                        en: 'Could not load learning journey.',
                        uk: 'Не вдалося завантажити навчальну подорож.',
                      ),
                      style: TextStyle(color: onSurface),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _refreshJourney(ref, userId),
                      child: Text(_tr(context, en: 'Retry', uk: 'Повторити')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (isLoadingCore && courses.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: _backgroundDecoration(isDarkTheme),
          child: const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    final nodes = _buildNodeSnapshots(courses, progress);
    final weakSpots = nodes.where((node) => node.isWeakSpot).toList()
      ..sort((a, b) => a.progress.compareTo(b.progress));
    final missions = _buildMissions(
      nodes: nodes,
      portfolioEntries: portfolioEntries,
      userData: userData,
      isUkr: isUkr,
    );
    final insights = _buildInsights(
      nodes: nodes,
      portfolioEntries: portfolioEntries,
      userData: userData,
      unlockedAchievements: achievements.length,
      isUkr: isUkr,
    );
    final recommendations = _buildRecommendations(
      nodes,
      userData,
      isUkr: isUkr,
    );

    final completedLessons = nodes.fold<int>(
      0,
      (sum, node) => sum + node.completedLessons,
    );
    final totalLessons = nodes.fold<int>(
      0,
      (sum, node) => sum + node.totalLessons,
    );
    final totalProgress = totalLessons == 0
        ? 0.0
        : completedLessons / totalLessons;

    return Scaffold(
      body: Container(
        decoration: _backgroundDecoration(isDarkTheme),
        child: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFF0066FF),
            onRefresh: () => _refreshJourney(ref, userId),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _buildHeader(context, onSurface, l10n),
                const SizedBox(height: 14),
                if (!onboardingDone)
                  _buildOnboardingCard(
                        context: context,
                        onSurface: onSurface,
                        isDarkTheme: isDarkTheme,
                        onDismiss: () async {
                          await ref
                              .read(learningJourneyActionsProvider)
                              .completeOnboarding(userId);
                        },
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.08, end: 0),
                if (!onboardingDone) const SizedBox(height: 14),
                _buildOverviewCard(
                      context: context,
                      levelInfo: levelInfo,
                      streak: userData?.currentStreak ?? 0,
                      totalXP: userData?.totalXP ?? 0,
                      achievementsCount: achievements.length,
                      totalProgress: totalProgress,
                      isDarkTheme: isDarkTheme,
                      onSurface: onSurface,
                    )
                    .animate()
                    .fadeIn(duration: 450.ms)
                    .slideY(begin: 0.08, end: 0),
                const SizedBox(height: 14),
                _buildSkillMapCard(
                  context: context,
                  nodes: nodes,
                  isDarkTheme: isDarkTheme,
                  onSurface: onSurface,
                  onNodeTap: (node) {
                    final course = courses.firstWhere(
                      (item) => item.id == node.courseId,
                      orElse: () => courses.first,
                    );
                    context.push('/course/${course.id}', extra: course);
                  },
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.08, end: 0),
                const SizedBox(height: 14),
                _buildWeakSpotsCard(
                  weakSpots: weakSpots,
                  isDarkTheme: isDarkTheme,
                  onSurface: onSurface,
                ).animate(delay: 130.ms).fadeIn().slideY(begin: 0.08, end: 0),
                const SizedBox(height: 14),
                _buildMissionsCard(
                  missions: missions,
                  isDarkTheme: isDarkTheme,
                  onSurface: onSurface,
                ).animate(delay: 160.ms).fadeIn().slideY(begin: 0.08, end: 0),
                const SizedBox(height: 14),
                _buildRecommendationsCard(
                  context: context,
                  recommendations: recommendations,
                  isDarkTheme: isDarkTheme,
                  onSurface: onSurface,
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.08, end: 0),
                const SizedBox(height: 14),
                _buildPortfolioCard(
                  context: context,
                  userId: userId,
                  entries: portfolioEntries,
                  isDarkTheme: isDarkTheme,
                  onSurface: onSurface,
                ).animate(delay: 240.ms).fadeIn().slideY(begin: 0.08, end: 0),
                const SizedBox(height: 14),
                _buildInsightsCard(
                  context: context,
                  insights: insights,
                  isDarkTheme: isDarkTheme,
                  onSurface: onSurface,
                ).animate(delay: 280.ms).fadeIn().slideY(begin: 0.08, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _backgroundDecoration(bool isDarkTheme) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkTheme
            ? const [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0D1B3A)]
            : const [Color(0xFFF8FAFF), Color(0xFFEEF3FF), Color(0xFFE6EEFF)],
      ),
    );
  }

  Future<void> _refreshJourney(WidgetRef ref, String userId) async {
    ref.invalidate(userDataProvider(userId));
    ref.invalidate(allUserProgressProvider);
    ref.invalidate(localizedCoursesProvider);
    ref.invalidate(achievementsProvider);
    ref.invalidate(levelInfoProvider);
    ref.invalidate(portfolioEntriesProvider(userId));
    ref.invalidate(learningJourneyOnboardingProvider(userId));
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  List<JourneyNodeSnapshot> _buildNodeSnapshots(
    List<Course> courses,
    List<CourseProgress> progressList,
  ) {
    return courses
        .map((course) {
          final progress = _findProgress(course.id, progressList);
          return JourneyNodeSnapshot(
            courseId: course.id,
            title: course.title,
            icon: course.icon,
            completedLessons: progress?.completedLessons.length ?? 0,
            totalLessons: course.totalLessons,
            order: course.order,
          );
        })
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  CourseProgress? _findProgress(
    String courseId,
    List<CourseProgress> progressList,
  ) {
    for (final progress in progressList) {
      if (_courseMatchesProgress(courseId, progress.courseId)) {
        return progress;
      }
    }
    return null;
  }

  bool _courseMatchesProgress(String courseId, String progressCourseId) {
    final normalizedCourseId = _normalizeCourseKey(courseId);
    final normalizedProgressId = _normalizeCourseKey(progressCourseId);
    return normalizedProgressId.contains(normalizedCourseId) ||
        normalizedCourseId.contains(normalizedProgressId);
  }

  String _normalizeCourseKey(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  List<JourneyMission> _buildMissions({
    required List<JourneyNodeSnapshot> nodes,
    required List<PortfolioEntry> portfolioEntries,
    required UserModel? userData,
    required bool isUkr,
  }) {
    final startedButIncomplete = nodes.any(
      (node) => node.isStarted && !node.isCompleted,
    );
    final today = DateTime.now();
    final hasEntryToday = portfolioEntries.any(
      (entry) => _isSameDay(entry.createdAt, today),
    );
    final activeToday =
        userData?.lastActive != null &&
        _isSameDay(userData!.lastActive!, today);

    return [
      JourneyMission(
        id: 'keep-streak',
        title: _trByLocale(
          isUkr,
          en: 'Keep streak alive',
          uk: 'Підтримай серію',
        ),
        description: _trByLocale(
          isUkr,
          en: 'Complete at least one lesson today.',
          uk: 'Заверши хоча б один урок сьогодні.',
        ),
        xpReward: 20,
        isCompleted: activeToday || (userData?.currentStreak ?? 0) > 0,
      ),
      JourneyMission(
        id: 'course-step',
        title: _trByLocale(
          isUkr,
          en: 'Push one step on Skill Map',
          uk: 'Зроби крок на карті навичок',
        ),
        description: startedButIncomplete
            ? _trByLocale(
                isUkr,
                en: 'Finish the next lesson in your current path.',
                uk: 'Заверши наступний урок у поточному шляху.',
              )
            : _trByLocale(
                isUkr,
                en: 'Start your first course node today.',
                uk: 'Почни перший вузол курсу сьогодні.',
              ),
        xpReward: 30,
        isCompleted: nodes.any((node) => node.progress >= 0.5),
      ),
      JourneyMission(
        id: 'portfolio-log',
        title: _trByLocale(
          isUkr,
          en: 'Log solution in Portfolio',
          uk: 'Збережи рішення в Portfolio',
        ),
        description: _trByLocale(
          isUkr,
          en: 'Save one code snippet with notes about your approach.',
          uk: 'Збережи один фрагмент коду з нотатками про підхід.',
        ),
        xpReward: 25,
        isCompleted: hasEntryToday,
      ),
    ];
  }

  List<String> _buildRecommendations(
    List<JourneyNodeSnapshot> nodes,
    UserModel? userData, {
    required bool isUkr,
  }) {
    if (nodes.isEmpty) {
      return <String>[
        _trByLocale(
          isUkr,
          en: 'Open your first course node to start the Developer Journey.',
          uk: 'Відкрий перший вузол курсу, щоб почати подорож розробника.',
        ),
      ];
    }

    final preferredLanguage = userData?.preferredLanguage.toLowerCase();
    final primaryNode = nodes.firstWhere(
      (node) =>
          !node.isCompleted &&
          (preferredLanguage == null ||
              preferredLanguage.isEmpty ||
              _normalizeCourseKey(
                node.courseId,
              ).contains(_normalizeCourseKey(preferredLanguage))),
      orElse: () => nodes.firstWhere(
        (node) => node.isStarted && !node.isCompleted,
        orElse: () => nodes.first,
      ),
    );

    final weakest =
        nodes
            .where((node) => node.isStarted && !node.isCompleted)
            .toList(growable: false)
          ..sort((a, b) => a.progress.compareTo(b.progress));

    final weakestNode = weakest.isNotEmpty ? weakest.first : null;
    final recommendations = <String>[
      _trByLocale(
        isUkr,
        en: 'Next best step: continue ${primaryNode.title} (${(primaryNode.progress * 100).round()}%).',
        uk: 'Найкращий наступний крок: продовжити ${primaryNode.title} (${(primaryNode.progress * 100).round()}%).',
      ),
    ];

    if (weakestNode != null && weakestNode.courseId != primaryNode.courseId) {
      recommendations.add(
        _trByLocale(
          isUkr,
          en: 'Weak spot detected in ${weakestNode.title}. Revisit one foundational lesson.',
          uk: 'Виявлено слабке місце у ${weakestNode.title}. Повтори один базовий урок.',
        ),
      );
    }

    if ((userData?.currentStreak ?? 0) < 3) {
      recommendations.add(
        _trByLocale(
          isUkr,
          en: 'Build a 3-day streak to unlock faster XP momentum and bonus rewards.',
          uk: 'Збери серію 3 дні, щоб отримати швидший XP-прогрес і бонуси.',
        ),
      );
    }

    return recommendations;
  }

  List<JourneyInsight> _buildInsights({
    required List<JourneyNodeSnapshot> nodes,
    required List<PortfolioEntry> portfolioEntries,
    required UserModel? userData,
    required int unlockedAchievements,
    required bool isUkr,
  }) {
    final completedLessons = nodes.fold<int>(
      0,
      (sum, node) => sum + node.completedLessons,
    );
    final completedCourses = nodes.where((node) => node.isCompleted).length;
    final topCourse =
        nodes.where((node) => node.completedLessons > 0).toList(growable: false)
          ..sort((a, b) => b.completedLessons.compareTo(a.completedLessons));
    final weakTags = <String, int>{};
    for (final entry in portfolioEntries.where((entry) => entry.hadErrors)) {
      for (final tag in entry.errorTags) {
        weakTags.update(
          tag.toLowerCase(),
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }
    final topWeakTag = weakTags.entries.isEmpty
        ? null
        : (weakTags.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;

    return [
      JourneyInsight(
        title: _trByLocale(isUkr, en: 'Growth momentum', uk: 'Динаміка росту'),
        description: _trByLocale(
          isUkr,
          en: 'You completed $completedLessons lessons and unlocked $unlockedAchievements achievements.',
          uk: 'Ти завершив(ла) $completedLessons уроків і відкрив(ла) $unlockedAchievements досягнень.',
        ),
      ),
      JourneyInsight(
        title: _trByLocale(
          isUkr,
          en: 'Strongest direction',
          uk: 'Найсильніший напрям',
        ),
        description: topCourse.isEmpty
            ? _trByLocale(
                isUkr,
                en: 'No dominant skill yet — complete 2 lessons in one track to reveal strength.',
                uk: 'Поки немає домінуючої навички — пройди 2 уроки в одному треку, щоб побачити силу.',
              )
            : _trByLocale(
                isUkr,
                en: '${topCourse.first.title} is your strongest track right now.',
                uk: '${topCourse.first.title} — зараз твій найсильніший трек.',
              ),
      ),
      JourneyInsight(
        title: _trByLocale(isUkr, en: 'Focus zone', uk: 'Зона фокусу'),
        description: topWeakTag == null
            ? _trByLocale(
                isUkr,
                en: 'Mark mistakes in Portfolio to get precise weak-spot analytics.',
                uk: 'Позначай помилки в портфоліо, щоб отримати точну аналітику слабких місць.',
              )
            : _trByLocale(
                isUkr,
                en: 'Most repeated struggle: ${topWeakTag.toUpperCase()}. Add one focused recap session.',
                uk: 'Найчастіша складність: ${topWeakTag.toUpperCase()}. Додай одну фокусну сесію повторення.',
              ),
      ),
      JourneyInsight(
        title: _trByLocale(
          isUkr,
          en: 'Level trajectory',
          uk: 'Траєкторія рівня',
        ),
        description: _trByLocale(
          isUkr,
          en: 'Level ${XPSystem.levelFromXP(userData?.totalXP ?? 0)} with $completedCourses completed course paths.',
          uk: 'Рівень ${XPSystem.levelFromXP(userData?.totalXP ?? 0)} і $completedCourses завершених треків курсів.',
        ),
      ),
    ];
  }

  Widget _buildHeader(
    BuildContext context,
    Color onSurface,
    AppLocalizations? l10n,
  ) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: onSurface),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.get('learning_history') ?? 'Learning History',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _tr(context, en: 'Developer Journey', uk: 'Подорож розробника'),
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingCard({
    required BuildContext context,
    required bool isDarkTheme,
    required Color onSurface,
    required Future<void> Function() onDismiss,
  }) {
    return _buildGlassSection(
      isDarkTheme: isDarkTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.explore_outlined,
                  color: Color(0xFF0066FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _tr(
                    context,
                    en: 'Welcome to Developer Journey',
                    uk: 'Ласкаво просимо до Подорожі розробника',
                  ),
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _tr(
              context,
              en: 'Track your path as a Skill Map, save your code portfolio, and use insights to improve weak spots.',
              uk: 'Відстежуй шлях через карту навичок, зберігай портфоліо коду та використовуй інсайти для роботи зі слабкими місцями.',
            ),
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.75),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onDismiss,
              icon: const Icon(Icons.rocket_launch_outlined, size: 18),
              label: Text(
                _tr(context, en: 'Start Journey', uk: 'Почати подорож'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required BuildContext context,
    required LevelInfo levelInfo,
    required int streak,
    required int totalXP,
    required int achievementsCount,
    required double totalProgress,
    required bool isDarkTheme,
    required Color onSurface,
  }) {
    return _buildGlassSection(
      isDarkTheme: isDarkTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(levelInfo.badge, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_tr(context, en: 'Level', uk: 'Рівень')} ${levelInfo.level} • ${_localizedLevelTitle(context, levelInfo.title)}',
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              Text(
                '${(totalProgress * 100).round()}%',
                style: const TextStyle(
                  color: Color(0xFF0066FF),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: totalProgress.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: isDarkTheme
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFD8E2FF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF0066FF),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _overviewChip(Icons.bolt, '$totalXP XP'),
              _overviewChip(
                Icons.local_fire_department,
                '$streak ${_tr(context, en: 'streak', uk: 'серія')}',
              ),
              _overviewChip(
                Icons.emoji_events_outlined,
                '$achievementsCount ${_tr(context, en: 'badges', uk: 'бейджі')}',
              ),
              _overviewChip(
                Icons.trending_up,
                '${levelInfo.xpNeededForNextLevel} ${_tr(context, en: 'XP to next level', uk: 'XP до наступного рівня')}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0066FF).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF0066FF)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1147A6),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillMapCard({
    required BuildContext context,
    required List<JourneyNodeSnapshot> nodes,
    required bool isDarkTheme,
    required Color onSurface,
    required void Function(JourneyNodeSnapshot node) onNodeTap,
  }) {
    return _buildGlassSection(
      isDarkTheme: isDarkTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, en: 'Skill Map Path', uk: 'Шлях карти навичок'),
            style: TextStyle(
              color: onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _tr(
              context,
              en: 'Tap a node to continue. Hover cards on web for quick status preview.',
              uk: 'Натисни вузол, щоб продовжити. У веб-версії наведи курсор на картку для швидкого статусу.',
            ),
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          if (nodes.isEmpty)
            Text(
              _tr(context, en: 'No courses found.', uk: 'Курси не знайдено.'),
              style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
            )
          else
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: nodes.length,
                separatorBuilder: (context, index) => Center(
                  child: Container(
                    width: 26,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: nodes[index].isCompleted
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFB7C8FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                itemBuilder: (context, index) {
                  final node = nodes[index];
                  final isHovered = _hoveredNodeId == node.courseId;
                  final statusColor = node.isCompleted
                      ? const Color(0xFF22C55E)
                      : node.isWeakSpot
                      ? const Color(0xFFF97316)
                      : const Color(0xFF0066FF);

                  return MouseRegion(
                    onEnter: (_) =>
                        setState(() => _hoveredNodeId = node.courseId),
                    onExit: (_) => setState(() => _hoveredNodeId = null),
                    child: AnimatedScale(
                      scale: isHovered ? 1.03 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      child: GestureDetector(
                        onTap: () => onNodeTap(node),
                        child: Container(
                          width: 142,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkTheme
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isHovered
                                  ? statusColor
                                  : statusColor.withValues(alpha: 0.35),
                              width: isHovered ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    node.icon,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      node.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: onSurface,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: node.progress,
                                  minHeight: 7,
                                  backgroundColor: isDarkTheme
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : const Color(0xFFD8E2FF),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${node.completedLessons}/${node.totalLessons} ${_tr(context, en: 'lessons', uk: 'уроків')}',
                                style: TextStyle(
                                  color: onSurface.withValues(alpha: 0.72),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                node.isCompleted
                                    ? _tr(
                                        context,
                                        en: 'Completed',
                                        uk: 'Завершено',
                                      )
                                    : node.isWeakSpot
                                    ? _tr(
                                        context,
                                        en: 'Needs focus',
                                        uk: 'Потрібен фокус',
                                      )
                                    : _tr(
                                        context,
                                        en: 'In progress',
                                        uk: 'У процесі',
                                      ),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeakSpotsCard({
    required List<JourneyNodeSnapshot> weakSpots,
    required bool isDarkTheme,
    required Color onSurface,
  }) {
    return _buildGlassSection(
      isDarkTheme: isDarkTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, en: 'Weak spots radar', uk: 'Радар слабких місць'),
            style: TextStyle(
              color: onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (weakSpots.isEmpty)
            Text(
              _tr(
                context,
                en: 'No major weak spots detected yet. Keep momentum!',
                uk: 'Поки немає критичних слабких місць. Тримай темп!',
              ),
              style: TextStyle(color: onSurface.withValues(alpha: 0.75)),
            )
          else
            ...weakSpots.take(3).map((spot) {
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF97316).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFF97316),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _tr(
                          context,
                          en: '${spot.title}: ${(spot.progress * 100).round()}% mastery. Revisit fundamentals.',
                          uk: '${spot.title}: ${(spot.progress * 100).round()}% засвоєння. Повтори фундамент.',
                        ),
                        style: TextStyle(
                          color: onSurface.withValues(alpha: 0.86),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMissionsCard({
    required List<JourneyMission> missions,
    required bool isDarkTheme,
    required Color onSurface,
  }) {
    return _buildGlassSection(
      isDarkTheme: isDarkTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, en: 'Daily Missions', uk: 'Щоденні місії'),
            style: TextStyle(
              color: onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ...missions.map((mission) {
            final statusColor = mission.isCompleted
                ? const Color(0xFF22C55E)
                : const Color(0xFF0066FF);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.22)),
              ),
              child: Row(
                children: [
                  Icon(
                    mission.isCompleted
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                    color: statusColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mission.title,
                          style: TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          mission.description,
                          style: TextStyle(
                            color: onSurface.withValues(alpha: 0.72),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${mission.xpReward} XP',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard({
    required BuildContext context,
    required List<String> recommendations,
    required bool isDarkTheme,
    required Color onSurface,
  }) {
    return _buildGlassSection(
      isDarkTheme: isDarkTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(
              context,
              en: 'Personal recommendations',
              uk: 'Персональні рекомендації',
            ),
            style: TextStyle(
              color: onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...recommendations.map((text) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF8B5CF6),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.84),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard({
    required BuildContext context,
    required String userId,
    required List<PortfolioEntry> entries,
    required bool isDarkTheme,
    required Color onSurface,
  }) {
    return _buildGlassSection(
      isDarkTheme: isDarkTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tr(context, en: 'Code Portfolio', uk: 'Портфоліо коду'),
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showAddPortfolioEntrySheet(context, userId),
                icon: const Icon(Icons.add, size: 16),
                label: Text(_tr(context, en: 'Add', uk: 'Додати')),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (entries.isEmpty)
            Text(
              _tr(
                context,
                en: 'Save your best solutions and mistakes to build a personal developer log.',
                uk: 'Зберігай найкращі рішення й помилки, щоб будувати персональний developer log.',
              ),
              style: TextStyle(color: onSurface.withValues(alpha: 0.75)),
            )
          else
            ...entries.take(5).map((entry) {
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkTheme
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: entry.hadErrors
                        ? const Color(0xFFF97316).withValues(alpha: 0.35)
                        : const Color(0xFF0066FF).withValues(alpha: 0.22),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: entry.hadErrors
                            ? const Color(0xFFF97316).withValues(alpha: 0.15)
                            : const Color(0xFF0066FF).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        entry.language.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${entry.language.toUpperCase()} • ${_formatRelativeDate(entry.createdAt, isUkr: _isUkrainianLocale(context))}',
                            style: TextStyle(
                              color: onSurface.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                          if (entry.errorTags.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: entry.errorTags.take(3).map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF97316,
                                    ).withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      color: Color(0xFFB45309),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await ref
                            .read(learningJourneyActionsProvider)
                            .removePortfolioEntry(
                              userId: userId,
                              entryId: entry.id,
                            );
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: onSurface.withValues(alpha: 0.55),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildInsightsCard({
    required BuildContext context,
    required List<JourneyInsight> insights,
    required bool isDarkTheme,
    required Color onSurface,
  }) {
    return _buildGlassSection(
      isDarkTheme: isDarkTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, en: 'Learning insights', uk: 'Навчальні інсайти'),
            style: TextStyle(
              color: onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ...insights.map((insight) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0066FF).withValues(alpha: 0.09),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: TextStyle(
                      color: onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insight.description,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.78),
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGlassSection({
    required bool isDarkTheme,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkTheme
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkTheme
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFFD6E2FF),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF0F172A,
            ).withValues(alpha: isDarkTheme ? 0.18 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _showAddPortfolioEntrySheet(
    BuildContext context,
    String userId,
  ) async {
    final titleController = TextEditingController();
    final snippetController = TextEditingController();
    final notesController = TextEditingController();
    final tagsController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String language = 'python';
    bool hadErrors = false;
    bool isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDarkTheme =
            Theme.of(sheetContext).brightness == Brightness.dark;
        final onSurface = Theme.of(sheetContext).colorScheme.onSurface;
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            Future<void> saveEntry() async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              setModalState(() => isSaving = true);

              final rawTags = tagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList(growable: false);

              await ref
                  .read(learningJourneyActionsProvider)
                  .addPortfolioEntry(
                    userId: userId,
                    entry: PortfolioEntry(
                      id: '${DateTime.now().millisecondsSinceEpoch}',
                      title: titleController.text.trim(),
                      language: language,
                      snippet: snippetController.text.trim(),
                      notes: notesController.text.trim(),
                      hadErrors: hadErrors,
                      errorTags: rawTags,
                      createdAt: DateTime.now(),
                    ),
                  );

              if (!sheetContext.mounted) return;
              Navigator.of(sheetContext).pop();
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                top: 16,
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkTheme ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tr(
                              sheetContext,
                              en: 'Add portfolio entry',
                              uk: 'Додати запис у portfolio',
                            ),
                            style: TextStyle(
                              color: onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: titleController,
                            validator: (value) =>
                                value == null || value.trim().length < 3
                                ? _tr(
                                    sheetContext,
                                    en: 'Title must be at least 3 characters',
                                    uk: 'Назва має бути щонайменше 3 символи',
                                  )
                                : null,
                            decoration: InputDecoration(
                              labelText: _tr(
                                sheetContext,
                                en: 'Title',
                                uk: 'Назва',
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            initialValue: language,
                            items: [
                              DropdownMenuItem(
                                value: 'python',
                                child: Text('Python'),
                              ),
                              DropdownMenuItem(
                                value: 'javascript',
                                child: Text('JavaScript'),
                              ),
                              DropdownMenuItem(
                                value: 'sql',
                                child: Text('SQL'),
                              ),
                              DropdownMenuItem(
                                value: 'dart',
                                child: Text('Dart'),
                              ),
                              DropdownMenuItem(
                                value: 'other',
                                child: Text(
                                  _tr(sheetContext, en: 'Other', uk: 'Інше'),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setModalState(() => language = value);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: _tr(
                                sheetContext,
                                en: 'Language',
                                uk: 'Мова',
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: snippetController,
                            maxLines: 5,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? _tr(
                                    sheetContext,
                                    en: 'Add code snippet or solution summary',
                                    uk: 'Додайте фрагмент коду або опис рішення',
                                  )
                                : null,
                            decoration: InputDecoration(
                              labelText: _tr(
                                sheetContext,
                                en: 'Code snippet / solution',
                                uk: 'Фрагмент коду / рішення',
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: notesController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: _tr(
                                sheetContext,
                                en: 'Notes (optional)',
                                uk: 'Нотатки (необовʼязково)',
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: hadErrors,
                            onChanged: (value) =>
                                setModalState(() => hadErrors = value),
                            title: Text(
                              _tr(
                                sheetContext,
                                en: 'I had difficulties in this task',
                                uk: 'У цьому завданні були труднощі',
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: tagsController,
                            maxLines: 1,
                            decoration: InputDecoration(
                              labelText: _tr(
                                sheetContext,
                                en: 'Error tags (comma separated)',
                                uk: 'Теги помилок (через кому)',
                              ),
                              hintText: _tr(
                                sheetContext,
                                en: 'loops, arrays, joins',
                                uk: 'цикли, масиви, joins',
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isSaving ? null : saveEntry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0066FF),
                                foregroundColor: Colors.white,
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      _tr(
                                        sheetContext,
                                        en: 'Save entry',
                                        uk: 'Зберегти запис',
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatRelativeDate(DateTime date, {required bool isUkr}) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) {
      return isUkr
          ? '${math.max(1, difference.inMinutes)} хв тому'
          : '${math.max(1, difference.inMinutes)}m ago';
    }
    if (difference.inHours < 24) {
      return isUkr
          ? '${difference.inHours} год тому'
          : '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return isUkr
          ? '${difference.inDays} д тому'
          : '${difference.inDays}d ago';
    }
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  bool _isUkrainianLocale(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'uk';
  }

  String _tr(BuildContext context, {required String en, required String uk}) {
    return _isUkrainianLocale(context) ? uk : en;
  }

  String _trByLocale(bool isUkr, {required String en, required String uk}) {
    return isUkr ? uk : en;
  }

  String _localizedLevelTitle(BuildContext context, String title) {
    if (!_isUkrainianLocale(context)) return title;

    const localized = <String, String>{
      'Novice': 'Новачок',
      'Apprentice': 'Початківець',
      'Student': 'Студент',
      'Coder': 'Кодер',
      'Developer': 'Розробник',
      'Senior Developer': 'Сеньйор-розробник',
      'Expert': 'Експерт',
      'Master': 'Майстер',
      'Guru': 'Гуру',
      'Legend': 'Легенда',
      'Code Wizard': 'Маг коду',
    };
    return localized[title] ?? title;
  }
}
