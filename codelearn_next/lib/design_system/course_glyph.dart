import 'package:flutter/material.dart';

IconData courseIcon(String courseId) =>
    switch (courseId.replaceAll('-intermediate', '')) {
      'python' => Icons.data_object_rounded,
      'javascript' => Icons.bolt_rounded,
      'programming-fundamentals' => Icons.lightbulb_outline_rounded,
      'logic-basics' => Icons.account_tree_outlined,
      'algorithms-basics' => Icons.schema_outlined,
      'cli-basics' => Icons.terminal_rounded,
      'internet-basics' => Icons.public_rounded,
      'cplusplus' => Icons.memory_rounded,
      'htmlcss' => Icons.palette_outlined,
      'react' => Icons.widgets_outlined,
      'sql' => Icons.storage_rounded,
      'git' => Icons.fork_right_rounded,
      _ => Icons.code_rounded,
    };

Color courseColor(String courseId) =>
    switch (courseId.replaceAll('-intermediate', '')) {
      'python' => const Color(0xFF0A84FF),
      'javascript' => const Color(0xFFFFD60A),
      'programming-fundamentals' => const Color(0xFF63E6BE),
      'logic-basics' => const Color(0xFFBF5AF2),
      'algorithms-basics' => const Color(0xFFFF375F),
      'cli-basics' => const Color(0xFF8E8E93),
      'internet-basics' => const Color(0xFF64D2FF),
      'cplusplus' => const Color(0xFF5E5CE6),
      'htmlcss' => const Color(0xFFFF453A),
      'react' => const Color(0xFF40C8E0),
      'sql' => const Color(0xFF30D158),
      'git' => const Color(0xFFFF9F0A),
      _ => const Color(0xFF8E8E93),
    };

class CourseGlyph extends StatelessWidget {
  final String courseId;
  final double size;
  const CourseGlyph(this.courseId, {super.key, this.size = 36});
  @override
  Widget build(BuildContext context) {
    final color = courseColor(courseId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * .28),
      ),
      child: Icon(
        courseIcon(courseId),
        size: size * .58,
        color: color.computeLuminance() > .5
            ? const Color(0xFF1A1A18)
            : Colors.white,
      ),
    );
  }
}
