import 'dart:convert';
import 'dart:io';

import 'package:untitled/core/services/course_content_service.dart';

void main(List<String> arguments) {
  final outputPath = arguments.isNotEmpty
      ? arguments.first
      : 'tool/generated_lessons/en';
  final outputDirectory = Directory(outputPath);
  outputDirectory.createSync(recursive: true);

  for (final courseId in CourseContentService.supportedCourseIds) {
    final lessons = CourseContentService.getLessonsForCourse(courseId);
    final payload = <String, dynamic>{
      'courseId': courseId,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(growable: false),
    };

    final file = File(
      '${outputDirectory.path}${Platform.pathSeparator}$courseId.json',
    );
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
    stdout.writeln('Exported $courseId -> ${file.path}');
  }
}
