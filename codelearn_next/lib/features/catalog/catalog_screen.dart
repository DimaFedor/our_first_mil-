import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../design_system/components.dart';
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
                'completed' => progress == course.lessonCount,
                'beginner' => course.difficulty == 'beginner',
                'intermediate' => course.difficulty == 'intermediate',
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
                        'beginner': context.l10n.beginner,
                        'intermediate': context.l10n.intermediate,
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
            const SizedBox(height: 24),
            if (filtered.isEmpty)
              EmptyState(
                icon: Icons.search_off_rounded,
                title: context.l10n.noResults,
                body: context.l10n.trySearch,
              )
            else
              LayoutBuilder(
                builder: (context, constraints) => Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: filtered
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
          return PageBody(
            maxWidth: 850,
            children: [
              Text(
                course?.title(data.preferences.uiLocale) ?? courseId,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.courseProgress(
                  data.completedIn(courseId),
                  lessons.length,
                ),
              ),
              const SizedBox(height: 26),
              for (var index = 0; index < lessons.length; index++) ...[
                if (index == 0 ||
                    lessons[index].moduleId != lessons[index - 1].moduleId)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '${index + 1}'.padLeft(2, '0'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      child: Icon(
                        data.completions.containsKey(lessons[index].id)
                            ? Icons.check_rounded
                            : index == 0 ||
                                  data.completions.containsKey(
                                    lessons[index - 1].id,
                                  )
                            ? Icons.play_arrow_rounded
                            : Icons.lock_outline_rounded,
                      ),
                    ),
                    title: Text(
                      lessons[index].title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      lessons[index].description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text('${lessons[index].xp} XP'),
                    onTap: () {
                      if (index > 0 &&
                          !data.completions.containsKey(
                            lessons[index - 1].id,
                          ) &&
                          !data.completions.containsKey(lessons[index].id)) {
                        showMessage(context, context.l10n.locked);
                        return;
                      }
                      context.push(
                        '/course/$courseId/lesson/${lessons[index].id}',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    ),
  );
}
