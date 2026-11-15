import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../design_system/components.dart';
import '../../design_system/course_glyph.dart';
import '../catalog/domain/content.dart';
import '../progress/domain/learning_data.dart';
import '../rewards/domain/reward_policy.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncContent(
    value: ref.watch(dataProvider),
    builder: (data) => AsyncContent(
      value: ref.watch(coursesProvider),
      builder: (courses) => Dashboard(data: data, courses: courses),
    ),
    retry: () => ref.invalidate(dataProvider),
  );
}

class Dashboard extends ConsumerWidget {
  final LearningData data;
  final List<Course> courses;
  const Dashboard({super.key, required this.data, required this.courses});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final locale = data.preferences.uiLocale;
    final active = courses
        .where(
          (course) =>
              data.completedIn(course.id) > 0 &&
              data.completedIn(course.id) < course.lessonCount,
        )
        .firstOrNull;
    final focus = data.profile['focus'] ?? 'python';
    final recommended =
        active ??
        courses.where((course) => course.id == focus).firstOrNull ??
        courses.first;
    final nextLesson = ref
        .watch(lessonsProvider(recommended.id))
        .value
        ?.where((lesson) => !data.completions.containsKey(lesson.id))
        .firstOrNull;
    final continuePath = nextLesson == null
        ? '/course/${recommended.id}'
        : '/course/${recommended.id}/lesson/${nextLesson.id}';
    final level = RewardPolicy.level(data.xp);
    final floor = RewardPolicy.threshold(level);
    final ceiling = RewardPolicy.threshold(level + 1);
    final today = RewardPolicy.dayKey(DateTime.now());
    final doneToday = data.completions.values.any(
      (item) => RewardPolicy.dayKey(item.at.toLocal()) == today,
    );
    return PageBody(
      maxWidth: 760,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                data.name.isEmpty ? l.guest : data.name,
                style: theme.textTheme.labelLarge,
              ),
            ),
            if (MediaQuery.sizeOf(context).width >= 900)
              IconButton(
                onPressed: () => context.push('/settings'),
                tooltip: l.settings,
                icon: const Icon(Icons.tune_rounded),
              ),
          ],
        ),
        Text(
          '${l.level} $level',
          style: theme.textTheme.headlineLarge?.copyWith(fontSize: 48),
        ),
        const SizedBox(height: 6),
        Text(
          [
            '${data.xp} XP',
            l.dayCount(data.streak),
            l.lessonCount(data.completions.length),
          ].join('  ·  '),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        LinearProgressIndicator(
          value: level == 100
              ? 1
              : ((data.xp - floor) / (ceiling - floor)).clamp(0, 1),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        if (level < 100) ...[
          const SizedBox(height: 8),
          Text(
            l.nextLevel((ceiling - data.xp).clamp(0, 9999999)),
            style: theme.textTheme.bodySmall,
          ),
        ],
        GroupedSection(
          title: l.continueLearning,
          children: [
            ListTile(
              leading: CourseGlyph(recommended.id, size: 44),
              title: Text(nextLesson?.title ?? recommended.title(locale)),
              subtitle: Text(
                '${recommended.title(locale)}  ·  ${l.courseProgress(data.completedIn(recommended.id), recommended.lessonCount)}',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(continuePath),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.push(continuePath),
            child: Text(l.continueLearning),
          ),
        ),
        GroupedSection(
          title: l.dailyGoal,
          children: [
            ListTile(
              leading: Icon(
                doneToday
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: doneToday ? const Color(0xFF30D158) : null,
              ),
              title: Text(doneToday ? l.goalComplete : l.lessonGoal),
              trailing: Text(
                doneToday ? '1/1' : '0/1',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        GroupedSection(
          title: l.learningFocus,
          trailing: TextButton(
            onPressed: () => context.go('/courses'),
            child: Text(l.all),
          ),
          children: [
            for (final course in courses.take(5))
              CourseRow(course: course, data: data),
          ],
        ),
      ],
    );
  }
}

class CourseRow extends StatelessWidget {
  final Course course;
  final LearningData data;
  const CourseRow({super.key, required this.course, required this.data});
  @override
  Widget build(BuildContext context) {
    final completed = data.completedIn(course.id);
    return ListTile(
      leading: CourseGlyph(course.id),
      title: Text(course.title(data.preferences.uiLocale)),
      subtitle: Text(
        context.l10n.courseProgress(completed, course.lessonCount),
      ),
      trailing: course.lessonCount > 0 && completed >= course.lessonCount
          ? const Icon(Icons.check_rounded, color: Color(0xFF30D158))
          : const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push('/course/${course.id}'),
    );
  }
}
