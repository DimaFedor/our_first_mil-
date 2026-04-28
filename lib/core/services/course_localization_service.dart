import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/courses/models/course_model.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_provider.dart';
import 'course_content_service.dart';
import 'runtime_translation_service.dart';

final localizedCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final locale = ref.watch(localeProvider);
  return CourseLocalizationService.getLocalizedCourses(locale);
});

class CourseLocalizationService {
  CourseLocalizationService._();

  static const String _fallbackLanguageCode = 'en';
  static final Map<String, List<Course>> _localizedCoursesCache =
      <String, List<Course>>{};

  static const List<_CourseDefinition> _knownCourseDefinitions = [
    _CourseDefinition(
      id: 'python',
      titleKey: 'python',
      titleFallback: 'Python',
      descriptionKey: 'python_desc',
      descriptionFallback: 'Learn the fundamentals of Python programming',
      icon: '🐍',
      color: Color(0xFF3776AB),
      difficultyKey: 'difficulty_beginner',
      difficultyFallback: 'Beginner',
      estimatedHours: 20,
      tags: [
        _LocalizedTextDescriptor('tag_programming', 'Programming'),
        _LocalizedTextDescriptor('tag_beginner_friendly', 'Beginner-friendly'),
        _LocalizedTextDescriptor('tag_popular', 'Popular'),
      ],
    ),
    _CourseDefinition(
      id: 'javascript',
      titleKey: 'javascript',
      titleFallback: 'JavaScript',
      descriptionKey: 'javascript_desc',
      descriptionFallback: 'Master modern JavaScript and ES6+',
      icon: '⚡',
      color: Color(0xFFF7DF1E),
      difficultyKey: 'difficulty_beginner',
      difficultyFallback: 'Beginner',
      estimatedHours: 16,
      tags: [
        _LocalizedTextDescriptor('tag_web_development', 'Web Development'),
        _LocalizedTextDescriptor('tag_frontend', 'Frontend'),
        _LocalizedTextDescriptor('tag_popular', 'Popular'),
      ],
    ),
    _CourseDefinition(
      id: 'programming-fundamentals',
      titleKey: 'programming_fundamentals',
      titleFallback: 'Programming Fundamentals',
      descriptionKey: 'programming_fundamentals_desc',
      descriptionFallback:
          'Learn core programming ideas in the easiest possible way',
      icon: '🧠',
      color: Color(0xFF6366F1),
      difficultyKey: 'difficulty_beginner',
      difficultyFallback: 'Beginner',
      estimatedHours: 14,
      tags: [
        _LocalizedTextDescriptor('tag_programming', 'Programming'),
        _LocalizedTextDescriptor('tag_beginner_friendly', 'Beginner-friendly'),
        _LocalizedTextDescriptor('tag_popular', 'Popular'),
      ],
    ),
    _CourseDefinition(
      id: 'logic-basics',
      titleKey: 'logic_basics',
      titleFallback: 'Variables, Loops, and Conditions',
      descriptionKey: 'logic_basics_desc',
      descriptionFallback:
          'Master beginner logic building blocks with simple real-life examples',
      icon: '🔁',
      color: Color(0xFF0EA5E9),
      difficultyKey: 'difficulty_beginner',
      difficultyFallback: 'Beginner',
      estimatedHours: 12,
      tags: [
        _LocalizedTextDescriptor('tag_programming', 'Programming'),
        _LocalizedTextDescriptor('tag_beginner_friendly', 'Beginner-friendly'),
        _LocalizedTextDescriptor('tag_modern', 'Modern'),
      ],
    ),
    _CourseDefinition(
      id: 'algorithms-basics',
      titleKey: 'algorithms_basics',
      titleFallback: 'Algorithms Basics',
      descriptionKey: 'algorithms_basics_desc',
      descriptionFallback:
          'Understand algorithms with practical step-by-step beginner tasks',
      icon: '🧩',
      color: Color(0xFF8B5CF6),
      difficultyKey: 'difficulty_beginner',
      difficultyFallback: 'Beginner',
      estimatedHours: 12,
      tags: [
        _LocalizedTextDescriptor('tag_programming', 'Programming'),
        _LocalizedTextDescriptor('tag_beginner_friendly', 'Beginner-friendly'),
        _LocalizedTextDescriptor('tag_data', 'Data'),
      ],
    ),
    _CourseDefinition(
      id: 'cli-basics',
      titleKey: 'cli_basics',
      titleFallback: 'CLI Basics',
      descriptionKey: 'cli_basics_desc',
      descriptionFallback:
          'Get comfortable with command-line workflows from zero',
      icon: '💻',
      color: Color(0xFF475569),
      difficultyKey: 'difficulty_beginner',
      difficultyFallback: 'Beginner',
      estimatedHours: 10,
      tags: [
        _LocalizedTextDescriptor('tag_programming', 'Programming'),
        _LocalizedTextDescriptor('tag_beginner_friendly', 'Beginner-friendly'),
        _LocalizedTextDescriptor('tag_modern', 'Modern'),
      ],
    ),
    _CourseDefinition(
      id: 'internet-basics',
      titleKey: 'internet_basics',
      titleFallback: 'How the Internet Works',
      descriptionKey: 'internet_basics_desc',
      descriptionFallback:
          'Learn internet fundamentals: DNS, HTTP, APIs, and browser behavior',
      icon: '🌐',
      color: Color(0xFF14B8A6),
      difficultyKey: 'difficulty_beginner',
      difficultyFallback: 'Beginner',
      estimatedHours: 10,
      tags: [
        _LocalizedTextDescriptor('tag_programming', 'Programming'),
        _LocalizedTextDescriptor('tag_beginner_friendly', 'Beginner-friendly'),
        _LocalizedTextDescriptor('tag_web_development', 'Web Development'),
      ],
    ),
    _CourseDefinition(
      id: 'cplusplus',
      titleKey: 'cplusplus',
      titleFallback: 'C++',
      descriptionKey: 'cplusplus_desc',
      descriptionFallback:
          'Build strong programming fundamentals with modern C++',
      icon: '⚙️',
      color: Color(0xFF00599C),
      difficultyKey: 'difficulty_beginner',
      difficultyFallback: 'Beginner',
      estimatedHours: 18,
      tags: [
        _LocalizedTextDescriptor('tag_programming', 'Programming'),
        _LocalizedTextDescriptor('tag_beginner_friendly', 'Beginner-friendly'),
        _LocalizedTextDescriptor('tag_modern', 'Modern'),
      ],
    ),
    _CourseDefinition(
      id: 'htmlcss',
      titleKey: 'html_css',
      titleFallback: 'HTML/CSS',
      descriptionKey: 'html_css_desc',
      descriptionFallback: 'Build beautiful websites with HTML and CSS',
      icon: '🎨',
      color: Color(0xFFE34F26),
      difficultyKey: 'difficulty_beginner',
      difficultyFallback: 'Beginner',
      estimatedHours: 12,
      tags: [
        _LocalizedTextDescriptor('tag_web_design', 'Web Design'),
        _LocalizedTextDescriptor('tag_frontend', 'Frontend'),
        _LocalizedTextDescriptor('tag_visual', 'Visual'),
      ],
    ),
    _CourseDefinition(
      id: 'react',
      titleKey: 'react',
      titleFallback: 'React',
      descriptionKey: 'react_desc',
      descriptionFallback: 'Create interactive UIs with React',
      icon: '⚛️',
      color: Color(0xFF61DAFB),
      difficultyKey: 'difficulty_intermediate',
      difficultyFallback: 'Intermediate',
      estimatedHours: 15,
      tags: [
        _LocalizedTextDescriptor('tag_frontend', 'Frontend'),
        _LocalizedTextDescriptor('tag_framework', 'Framework'),
        _LocalizedTextDescriptor('tag_modern', 'Modern'),
      ],
    ),
    _CourseDefinition(
      id: 'sql',
      titleKey: 'sql',
      titleFallback: 'SQL',
      descriptionKey: 'sql_desc',
      descriptionFallback: 'Master database queries with SQL',
      icon: '🗄️',
      color: Color(0xFF4479A1),
      difficultyKey: 'difficulty_beginner',
      difficultyFallback: 'Beginner',
      estimatedHours: 14,
      tags: [
        _LocalizedTextDescriptor('tag_database', 'Database'),
        _LocalizedTextDescriptor('tag_backend', 'Backend'),
        _LocalizedTextDescriptor('tag_data', 'Data'),
      ],
    ),
    _CourseDefinition(
      id: 'git',
      titleKey: 'git',
      titleFallback: 'Git & GitHub',
      descriptionKey: 'git_desc',
      descriptionFallback:
          'Learn version control basics with branching and merging workflows',
      icon: '🌳',
      color: Color(0xFFF97316),
      difficultyKey: 'difficulty_beginner',
      difficultyFallback: 'Beginner',
      estimatedHours: 10,
      tags: [
        _LocalizedTextDescriptor('tag_programming', 'Programming'),
        _LocalizedTextDescriptor('tag_beginner_friendly', 'Beginner-friendly'),
        _LocalizedTextDescriptor('tag_modern', 'Modern'),
      ],
    ),
    _CourseDefinition(
      id: 'python-intermediate',
      titleKey: 'python_intermediate',
      titleFallback: 'Python Intermediate',
      descriptionKey: 'python_intermediate_desc',
      descriptionFallback: 'OOP, decorators, generators and advanced patterns',
      icon: '🐍',
      color: Color(0xFF306998),
      difficultyKey: 'difficulty_intermediate',
      difficultyFallback: 'Intermediate',
      estimatedHours: 12,
      tags: [
        _LocalizedTextDescriptor('tag_programming', 'Programming'),
        _LocalizedTextDescriptor('tag_oop', 'OOP'),
        _LocalizedTextDescriptor('tag_advanced', 'Advanced'),
      ],
    ),
    _CourseDefinition(
      id: 'cplusplus-intermediate',
      titleKey: 'cplusplus_intermediate',
      titleFallback: 'C++ Intermediate',
      descriptionKey: 'cplusplus_intermediate_desc',
      descriptionFallback:
          'Deepen C++ skills with OOP, templates, STL, and memory safety',
      icon: '⚙️',
      color: Color(0xFF004482),
      difficultyKey: 'difficulty_intermediate',
      difficultyFallback: 'Intermediate',
      estimatedHours: 14,
      tags: [
        _LocalizedTextDescriptor('tag_programming', 'Programming'),
        _LocalizedTextDescriptor('tag_advanced', 'Advanced'),
        _LocalizedTextDescriptor('tag_modern', 'Modern'),
      ],
    ),
    _CourseDefinition(
      id: 'htmlcss-intermediate',
      titleKey: 'html_css_intermediate',
      titleFallback: 'HTML/CSS Intermediate',
      descriptionKey: 'html_css_intermediate_desc',
      descriptionFallback: 'Flexbox, Grid, animations and responsive design',
      icon: '🎨',
      color: Color(0xFFCC6699),
      difficultyKey: 'difficulty_intermediate',
      difficultyFallback: 'Intermediate',
      estimatedHours: 10,
      tags: [
        _LocalizedTextDescriptor('tag_web_design', 'Web Design'),
        _LocalizedTextDescriptor('tag_layout', 'Layout'),
        _LocalizedTextDescriptor('tag_responsive', 'Responsive'),
      ],
    ),
    _CourseDefinition(
      id: 'javascript-intermediate',
      titleKey: 'javascript_intermediate',
      titleFallback: 'JavaScript Intermediate',
      descriptionKey: 'javascript_intermediate_desc',
      descriptionFallback: 'ES6+, async/await, and functional programming',
      icon: '🟨',
      color: Color(0xFFD4A017),
      difficultyKey: 'difficulty_intermediate',
      difficultyFallback: 'Intermediate',
      estimatedHours: 12,
      tags: [
        _LocalizedTextDescriptor('tag_programming', 'Programming'),
        _LocalizedTextDescriptor('tag_es6', 'ES6'),
        _LocalizedTextDescriptor('tag_async', 'Async'),
      ],
    ),
    _CourseDefinition(
      id: 'sql-intermediate',
      titleKey: 'sql_intermediate',
      titleFallback: 'SQL Intermediate',
      descriptionKey: 'sql_intermediate_desc',
      descriptionFallback: 'JOINs, subqueries, and window functions',
      icon: '🗄️',
      color: Color(0xFF336791),
      difficultyKey: 'difficulty_intermediate',
      difficultyFallback: 'Intermediate',
      estimatedHours: 12,
      tags: [
        _LocalizedTextDescriptor('tag_database', 'Database'),
        _LocalizedTextDescriptor('tag_analytics', 'Analytics'),
        _LocalizedTextDescriptor('tag_advanced', 'Advanced'),
      ],
    ),
    _CourseDefinition(
      id: 'react-intermediate',
      titleKey: 'react_intermediate',
      titleFallback: 'React Intermediate',
      descriptionKey: 'react_intermediate_desc',
      descriptionFallback: 'Hooks, Context, and performance optimization',
      icon: '⚛️',
      color: Color(0xFF00D8FF),
      difficultyKey: 'difficulty_intermediate',
      difficultyFallback: 'Intermediate',
      estimatedHours: 14,
      tags: [
        _LocalizedTextDescriptor('tag_frontend', 'Frontend'),
        _LocalizedTextDescriptor('tag_hooks', 'Hooks'),
        _LocalizedTextDescriptor('tag_state', 'State'),
      ],
    ),
  ];

  static Future<List<Course>> getLocalizedCourses(Locale locale) async {
    final languageCode = _normalizedLanguageCode(locale.languageCode);
    final cachedCourses = _localizedCoursesCache[languageCode];
    if (cachedCourses != null) {
      return cachedCourses;
    }

    final l10n = await AppLocalizations.load(locale);
    final fallbackL10n = await AppLocalizations.load(
      const Locale(_fallbackLanguageCode),
    );

    final knownById = <String, _CourseDefinition>{
      for (final definition in _knownCourseDefinitions)
        definition.id: definition,
    };

    final allDefinitions = CourseContentService.supportedCourseIds
        .map(
          (courseId) =>
              knownById[courseId] ?? _buildFallbackDefinition(courseId),
        )
        .toList(growable: false);

    final localizedCourses = await Future.wait(
      allDefinitions.map(
        (definition) => _buildLocalizedCourse(
          definition: definition,
          languageCode: languageCode,
          l10n: l10n,
          fallbackL10n: fallbackL10n,
        ),
      ),
    );

    final immutableCourses = List<Course>.unmodifiable(localizedCourses);
    _localizedCoursesCache[languageCode] = immutableCourses;
    return immutableCourses;
  }

  static Future<Course> _buildLocalizedCourse({
    required _CourseDefinition definition,
    required String languageCode,
    required AppLocalizations l10n,
    required AppLocalizations fallbackL10n,
  }) async {
    final title = await _resolveText(
      descriptor: _LocalizedTextDescriptor(
        definition.titleKey,
        definition.titleFallback,
      ),
      languageCode: languageCode,
      l10n: l10n,
      fallbackL10n: fallbackL10n,
    );
    final description = await _resolveText(
      descriptor: _LocalizedTextDescriptor(
        definition.descriptionKey,
        definition.descriptionFallback,
      ),
      languageCode: languageCode,
      l10n: l10n,
      fallbackL10n: fallbackL10n,
    );
    final difficulty = await _resolveText(
      descriptor: _LocalizedTextDescriptor(
        definition.difficultyKey,
        definition.difficultyFallback,
      ),
      languageCode: languageCode,
      l10n: l10n,
      fallbackL10n: fallbackL10n,
    );
    final tags = await Future.wait(
      definition.tags.map(
        (tag) => _resolveText(
          descriptor: tag,
          languageCode: languageCode,
          l10n: l10n,
          fallbackL10n: fallbackL10n,
        ),
      ),
    );

    final totalLessons = CourseContentService.getLessonsForCourse(
      definition.id,
    ).length;

    return Course(
      id: definition.id,
      title: title,
      description: description,
      icon: definition.icon,
      color: definition.color,
      difficulty: difficulty,
      totalLessons: totalLessons,
      estimatedHours: definition.estimatedHours,
      tags: tags,
      order: definition.order,
    );
  }

  static Future<String> _resolveText({
    required _LocalizedTextDescriptor descriptor,
    required String languageCode,
    required AppLocalizations l10n,
    required AppLocalizations fallbackL10n,
  }) async {
    final localizedText = l10n.get(descriptor.key);
    final fallbackFromL10n = fallbackL10n.get(descriptor.key);
    final fallbackText = fallbackFromL10n == descriptor.key
        ? descriptor.fallback
        : fallbackFromL10n;

    if (languageCode == _fallbackLanguageCode) {
      return localizedText == descriptor.key ? fallbackText : localizedText;
    }

    if (localizedText != fallbackText && localizedText != descriptor.key) {
      return localizedText;
    }

    try {
      return await RuntimeTranslationService.translateText(
        text: fallbackText,
        targetLanguageCode: languageCode,
      );
    } catch (e) {
      // If runtime translation fails, fall back to the fallback text
      debugPrint(
        'Runtime translation failed for "$languageCode": $e. Using fallback text.',
      );
      return fallbackText;
    }
  }

  static _CourseDefinition _buildFallbackDefinition(String courseId) {
    final normalizedId = courseId.trim();
    final isIntermediate = normalizedId.contains('intermediate');
    final titleWords = normalizedId
        .replaceAll('-', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .toList(growable: false);
    final generatedTitle = titleWords.join(' ');
    final generatedDescription = isIntermediate
        ? 'Continue your $generatedTitle learning journey'
        : 'Learn the fundamentals of $generatedTitle';

    final hue = normalizedId.hashCode.abs() % 360;
    final color = HSVColor.fromAHSV(1, hue.toDouble(), 0.65, 0.75).toColor();

    return _CourseDefinition(
      id: normalizedId,
      titleKey: normalizedId,
      titleFallback: generatedTitle,
      descriptionKey: '${normalizedId}_desc',
      descriptionFallback: generatedDescription,
      icon: isIntermediate ? '🚀' : '📚',
      color: color,
      difficultyKey: isIntermediate
          ? 'difficulty_intermediate'
          : 'difficulty_beginner',
      difficultyFallback: isIntermediate ? 'Intermediate' : 'Beginner',
      estimatedHours: math.max(
        1,
        (CourseContentService.getLessonsForCourse(normalizedId).length * 1.5)
            .round(),
      ),
      tags: const [_LocalizedTextDescriptor('tag_programming', 'Programming')],
      order: 999,
    );
  }

  static String _normalizedLanguageCode(String rawLanguageCode) {
    final normalized = rawLanguageCode.trim().toLowerCase();
    if (normalized.isEmpty) {
      return _fallbackLanguageCode;
    }
    return normalized;
  }
}

class _LocalizedTextDescriptor {
  final String key;
  final String fallback;

  const _LocalizedTextDescriptor(this.key, this.fallback);
}

class _CourseDefinition {
  final String id;
  final String titleKey;
  final String titleFallback;
  final String descriptionKey;
  final String descriptionFallback;
  final String icon;
  final Color color;
  final String difficultyKey;
  final String difficultyFallback;
  final int estimatedHours;
  final List<_LocalizedTextDescriptor> tags;
  final int order;

  const _CourseDefinition({
    required this.id,
    required this.titleKey,
    required this.titleFallback,
    required this.descriptionKey,
    required this.descriptionFallback,
    required this.icon,
    required this.color,
    required this.difficultyKey,
    required this.difficultyFallback,
    required this.estimatedHours,
    required this.tags,
    this.order = 0,
  });
}
