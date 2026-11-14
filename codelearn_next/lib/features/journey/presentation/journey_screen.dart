import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../design_system/components.dart';
import '../../../design_system/course_glyph.dart';
import '../../../foundation/json.dart';
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
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                StatPill(Icons.bolt_rounded, '${data.xp} XP'),
                StatPill(
                  Icons.local_fire_department_rounded,
                  l.dayCount(data.streak),
                ),
                StatPill(
                  Icons.school_outlined,
                  l.lessonCount(data.completions.length),
                ),
              ],
            ),
            SectionHeading(l.missions),
            Panel(
              child: Column(
                children: [
                  CheckboxListTile(
                    value: didLesson,
                    onChanged: null,
                    title: Text(l.missionLesson),
                    secondary: const Icon(Icons.school_outlined),
                  ),
                  CheckboxListTile(
                    value: didPortfolio,
                    onChanged: null,
                    title: Text(l.missionPortfolio),
                    secondary: const Icon(Icons.bookmark_border_rounded),
                  ),
                ],
              ),
            ),
            SectionHeading(l.skillMap),
            Panel(
              child: Column(
                children: [
                  for (var index = 0; index < courses.length; index++) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child:
                            data.completedIn(courses[index].id) ==
                                courses[index].lessonCount
                            ? const Icon(Icons.check_rounded)
                            : Icon(courseIcon(courses[index].id)),
                      ),
                      title: Text(
                        courses[index].title(data.preferences.uiLocale),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: LinearProgressIndicator(
                          value:
                              data.completedIn(courses[index].id) /
                              courses[index].lessonCount,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_rounded),
                      onTap: () => context.push('/course/${courses[index].id}'),
                    ),
                    if (index < courses.length - 1)
                      const Padding(
                        padding: EdgeInsetsDirectional.only(start: 19),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: SizedBox(
                            height: 20,
                            child: VerticalDivider(width: 1),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            SectionHeading(l.insights),
            if (weakCourses.isEmpty)
              Panel(
                child: Text(
                  data.completions.isEmpty ? l.noInsights : l.goalComplete,
                ),
              )
            else
              for (final weak in weakCourses.take(3))
                ListTile(
                  leading: const Icon(Icons.psychology_outlined),
                  title: Text(
                    courses
                            .where((item) => item.id == weak.key)
                            .firstOrNull
                            ?.title(data.preferences.uiLocale) ??
                        weak.key,
                  ),
                  subtitle: Text(l.practiceAgain),
                  onTap: () => context.push('/course/${weak.key}'),
                ),
            SectionHeading(
              l.portfolio,
              trailing: TextButton(
                onPressed: () => context.push('/portfolio'),
                child: Text(l.all),
              ),
            ),
            Panel(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.code_rounded),
                title: Text(l.portfolio),
                subtitle: Text(
                  data.portfolio.isEmpty
                      ? l.portfolioEmptyBody
                      : '${data.portfolio.length}',
                ),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () => context.push('/portfolio'),
              ),
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
