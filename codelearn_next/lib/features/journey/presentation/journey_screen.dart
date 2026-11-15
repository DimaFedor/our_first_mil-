import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../design_system/components.dart';
import '../../../design_system/course_glyph.dart';
import '../../../foundation/json.dart';
import '../../home/home_screen.dart';
import '../../rewards/domain/reward_policy.dart';
import '../../progress/domain/achievement.dart';

String achievementLabel(BuildContext context, String id) {
  final achievement = achievementDefinitions
      .where((item) => item.id == id)
      .firstOrNull;
  if (achievement == null) return context.l10n.achievements;
  return switch (achievement.kind) {
    AchievementKind.lessons => context.l10n.achievementLessons(
      achievement.requirement,
    ),
    AchievementKind.streak => context.l10n.achievementStreak(
      achievement.requirement,
    ),
    AchievementKind.xp => '${achievement.requirement} XP',
    AchievementKind.courses => context.l10n.achievementCourses(
      achievement.requirement,
    ),
  };
}

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncContent(
    value: ref.watch(dataProvider),
    builder: (data) => AsyncContent(
      value: ref.watch(coursesProvider),
      builder: (courses) {
        final l = context.l10n;
        final today = RewardPolicy.dayKey(DateTime.now());
        final didLesson = data.completions.values.any(
          (item) => RewardPolicy.dayKey(item.at.toLocal()) == today,
        );
        final didPortfolio = data.portfolio.any(
          (item) => RewardPolicy.dayKey(item.at.toLocal()) == today,
        );
        final struggled = <String, int>{};
        for (final attempt in data.attempts.where(
          (item) => item['passed'] == false,
        )) {
          final course = jsonString(attempt['courseId']);
          struggled.update(course, (count) => count + 1, ifAbsent: () => 1);
        }
        final weakCourses = struggled.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return PageBody(
          children: [
            Text(l.journey, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              [
                '${data.xp} XP',
                l.dayCount(data.streak),
                l.lessonCount(data.completions.length),
              ].join('  ·  '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            GroupedSection(
              title: l.missions,
              children: [
                for (final (isDone, label) in [
                  (didLesson, l.missionLesson),
                  (didPortfolio, l.missionPortfolio),
                ])
                  ListTile(
                    leading: Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isDone ? const Color(0xFF30D158) : null,
                    ),
                    title: Text(label),
                  ),
              ],
            ),
            GroupedSection(
              title: l.skillMap,
              children: [
                for (final course in courses)
                  CourseRow(course: course, data: data),
              ],
            ),
            GroupedSection(
              title: l.insights,
              children: [
                if (weakCourses.isEmpty)
                  ListTile(
                    title: Text(
                      data.completions.isEmpty ? l.noInsights : l.goalComplete,
                    ),
                  ),
                for (final weak in weakCourses.take(3))
                  ListTile(
                    leading: CourseGlyph(weak.key),
                    title: Text(
                      courses
                              .where((item) => item.id == weak.key)
                              .firstOrNull
                              ?.title(data.preferences.uiLocale) ??
                          weak.key,
                    ),
                    subtitle: Text(l.practiceAgain),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/course/${weak.key}'),
                  ),
              ],
            ),
            GroupedSection(
              title: l.portfolio,
              children: [
                ListTile(
                  leading: const Icon(Icons.code_rounded),
                  title: Text(l.portfolio),
                  subtitle: Text(
                    data.portfolio.isEmpty
                        ? l.portfolioEmptyBody
                        : '${data.portfolio.length}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/portfolio'),
                ),
              ],
            ),
            SectionHeading(l.achievements),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: achievementDefinitions
                  .map((item) => item.id)
                  .map(
                    (id) => SizedBox(
                      width: 170,
                      child: Panel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              data.achievements.contains(id)
                                  ? Icons.workspace_premium_rounded
                                  : Icons.lock_outline_rounded,
                              color: data.achievements.contains(id)
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).disabledColor,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              achievementLabel(context, id),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    ),
  );
}
