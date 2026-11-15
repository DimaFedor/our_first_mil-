import 'package:flutter/material.dart';

import '../../../design_system/components.dart';
import '../../catalog/domain/content.dart';
import '../../practice/presentation/practice_views.dart';
import '../domain/learning_session.dart';

List<Widget> buildTheory(
  BuildContext context,
  Lesson lesson,
  LearningSession session,
  ValueChanged<LearningSession> update,
  ValueChanged<LearningStage> moveTo,
) {
  final slides = lesson.slides;
  final l = context.l10n;
  if (slides.isEmpty) {
    return [
      FilledButton(
        onPressed: () => moveTo(LearningStage.quiz),
        child: Text(l.next),
      ),
    ];
  }
  final index = session.slideIndex.clamp(0, slides.length - 1);
  final slide = slides[index];
  return [
    LinearProgressIndicator(
      value: (index + 1) / slides.length,
      minHeight: 3,
      borderRadius: BorderRadius.circular(2),
    ),
    const SizedBox(height: 10),
    Text(
      '${index + 1} / ${slides.length}',
      style: Theme.of(context).textTheme.labelLarge,
    ),
    const SizedBox(height: 26),
    Text(slide.title, style: Theme.of(context).textTheme.headlineMedium),
    const SizedBox(height: 20),
    SelectableText(
      slide.content,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(fontSize: 17, height: 1.7),
    ),
    if (slide.code.isNotEmpty) ...[
      const SizedBox(height: 24),
      CodePanel(code: slide.code, language: slide.language),
    ],
    const SizedBox(height: 32),
    Row(
      children: [
        if (index > 0)
          TextButton.icon(
            onPressed: () => update(session.copyWith(slideIndex: index - 1)),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(l.back),
          ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () {
            if (index + 1 < slides.length) {
              update(session.copyWith(slideIndex: index + 1));
            } else {
              moveTo(LearningStage.quiz);
            }
          },
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(l.next),
        ),
      ],
    ),
  ];
}
