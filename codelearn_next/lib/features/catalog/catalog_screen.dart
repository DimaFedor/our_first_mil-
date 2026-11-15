import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../design_system/components.dart';
import '../../design_system/course_glyph.dart';
import 'domain/content.dart';
import '../home/home_screen.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});
  @override
  ConsumerState<CatalogScreen> createState() => CatalogScreenState();
}

class CatalogScreenState extends ConsumerState<CatalogScreen> {
  String query = '';
  String filter = 'all';
  @override
  Widget build(BuildContext context) => AsyncContent(
    value: ref.watch(dataProvider),
    builder: (data) => AsyncContent(
      value: ref.watch(coursesProvider),
      builder: (courses) {
        final filtered = courses.where((course) {
          final progress = data.completedIn(course.id);
          return course
                  .title(data.preferences.uiLocale)
                  .toLowerCase()
                  .contains(query.toLowerCase()) &&
              switch (filter) {
                'inProgress' => progress > 0 && progress < course.lessonCount,
                'completed' => progress >= course.lessonCount,
                _ => true,
              };
        }).toList();
        return PageBody(
          children: [
            Text(
              context.l10n.courses,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.welcomeBody),
            const SizedBox(height: 24),
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: context.l10n.searchCourses,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  {
                        'all': context.l10n.all,
                        'inProgress': context.l10n.inProgress,
                        'completed': context.l10n.completed,
                      }.entries
                      .map(
                        (entry) => ChoiceChip(
                          label: Text(entry.value),
                          selected: filter == entry.key,
                          onSelected: (value) =>
                              setState(() => filter = entry.key),
                        ),
                      )
                      .toList(),
            ),
            if (filtered.isEmpty)
              EmptyState(
                icon: Icons.search_off_rounded,
                title: context.l10n.noResults,
                body: context.l10n.trySearch,
              ),
            for (final (difficulty, label) in [
              ('beginner', context.l10n.beginner),
              ('intermediate', context.l10n.intermediate),
            ])
              if (filtered.any((course) => course.difficulty == difficulty))
                GroupedSection(
                  title: label,
                  children: [
                    for (final course in filtered.where(
                      (course) => course.difficulty == difficulty,
                    ))
                      CourseRow(course: course, data: data),
                  ],
                ),
          ],
        );
      },
    ),
  );
}

class CourseScreen extends ConsumerWidget {
  final String courseId;
  const CourseScreen({super.key, required this.courseId});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.courses)),
    body: AsyncContent(
      value: ref.watch(dataProvider),
      builder: (data) => AsyncContent(
        value: ref.watch(lessonsProvider(courseId)),
        retry: () => ref.invalidate(lessonsProvider(courseId)),
        builder: (lessons) {
          final course = ref
              .watch(coursesProvider)
              .value
              ?.where((item) => item.id == courseId)
              .firstOrNull;
          final completed = data.completedIn(courseId);
          return PageBody(
            maxWidth: 760,
            children: [
              CourseGlyph(courseId, size: 52),
              const SizedBox(height: 18),
              Text(
                course?.title(data.preferences.uiLocale) ?? courseId,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.courseProgress(completed, lessons.length),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: lessons.isEmpty ? 0 : completed / lessons.length,
                color: courseColor(courseId),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 12),
              GroupedSection(
                children: [
                  for (var index = 0; index < lessons.length; index++)
                    LessonRow(
                      lesson: lessons[index],
                      position: index + 1,
                      isDone: data.completions.containsKey(lessons[index].id),
                      isOpen:
                          index == 0 ||
                          data.completions.containsKey(lessons[index - 1].id),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}

class LessonRow extends StatelessWidget {
  final Lesson lesson;
  final int position;
  final bool isDone;
  final bool isOpen;
  const LessonRow({
    super.key,
    required this.lesson,
    required this.position,
    required this.isDone,
    required this.isOpen,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDone
              ? courseColor(lesson.courseId)
              : isOpen
              ? scheme.primary
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isDone
            ? Icon(
                Icons.check_rounded,
                size: 20,
                color: courseColor(lesson.courseId).computeLuminance() > .5
                    ? const Color(0xFF1A1A18)
                    : Colors.white,
              )
            : isOpen
            ? Icon(Icons.play_arrow_rounded, size: 20, color: scheme.onPrimary)
            : Text('$position', style: Theme.of(context).textTheme.labelLarge),
      ),
      title: Text(lesson.title),
      subtitle: Text(
        lesson.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${lesson.xp} XP',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        if (!isOpen && !isDone) {
          showMessage(context, context.l10n.locked);
          return;
        }
        context.push('/course/${lesson.courseId}/lesson/${lesson.id}');
      },
    );
  }
}
