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
