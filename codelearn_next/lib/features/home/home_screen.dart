import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../design_system/components.dart';
import '../../design_system/course_glyph.dart';
import '../../design_system/theme.dart';
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
    final level = RewardPolicy.level(data.xp);
    final today = RewardPolicy.dayKey(DateTime.now());
    final doneToday = data.completions.values.any(
      (item) => RewardPolicy.dayKey(item.at.toLocal()) == today,
    );
    return PageBody(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name.isEmpty ? l.guest : data.name,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.welcomeTitle,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.push('/settings'),
              tooltip: l.settings,
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 10,
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
        const SizedBox(height: 26),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF333C88), Color(0xFF20294D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.all(28),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.continueLearning.toUpperCase(),
                      style: const TextStyle(
                        color: brandMint,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      recommended.title(locale),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.courseProgress(
                        data.completedIn(recommended.id),
                        recommended.lessonCount,
                      ),
                      style: const TextStyle(color: Color(0xFFCBD1F6)),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () =>
                          context.push('/course/${recommended.id}'),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(l.continueLearning),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.sizeOf(context).width > 700)
                const Padding(
                  padding: EdgeInsets.all(25),
                  child: Icon(
                    Icons.terminal_rounded,
                    size: 100,
                    color: Color(0xFF8B96F4),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Panel(
          child: Row(
            children: [
              Icon(
                doneToday
                    ? Icons.check_circle_rounded
                    : Icons.track_changes_rounded,
                color: doneToday
                    ? brandMint
                    : Theme.of(context).colorScheme.primary,
                size: 34,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doneToday ? l.goalComplete : l.dailyGoal,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(l.lessonGoal),
                  ],
                ),
              ),
              Icon(
                doneToday ? Icons.done_rounded : Icons.chevron_right_rounded,
              ),
            ],
          ),
        ),
        SectionHeading(
          l.learningFocus,
          trailing: TextButton(
            onPressed: () => context.go('/courses'),
            child: Text(l.all),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: courses
                .take(6)
                .map(
                  (course) => SizedBox(
                    width: constraints.maxWidth > 800
                        ? (constraints.maxWidth - 32) / 3
                        : constraints.maxWidth > 500
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth,
                    child: CourseTile(course: course, data: data),
                  ),
                )
                .toList(),
          ),
        ),
        SectionHeading('${l.level} $level'),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.nextLevel(
                  (RewardPolicy.threshold(level + 1) - data.xp).clamp(
                    0,
                    9999999,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: level == 100
                    ? 1
                    : ((data.xp - RewardPolicy.threshold(level)) /
                              (RewardPolicy.threshold(level + 1) -
                                  RewardPolicy.threshold(level)))
                          .clamp(0, 1),
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CourseTile extends StatelessWidget {
  final Course course;
  final LearningData data;
  const CourseTile({super.key, required this.course, required this.data});
  @override
  Widget build(BuildContext context) {
    final completed = data.completedIn(course.id);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/course/${course.id}'),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    courseIcon(course.id),
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Spacer(),
                  Icon(
                    completed == course.lessonCount
                        ? Icons.check_circle_rounded
                        : Icons.north_east_rounded,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                course.title(data.preferences.uiLocale),
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.courseProgress(completed, course.lessonCount),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: course.lessonCount == 0
                    ? 0
                    : completed / course.lessonCount,
                minHeight: 4,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
