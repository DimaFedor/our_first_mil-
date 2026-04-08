import 'package:flutter/material.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final String difficulty;
  final int totalLessons;
  final int estimatedHours;
  final List<String> tags;
  final int order;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.totalLessons,
    required this.estimatedHours,
    required this.tags,
    this.order = 0,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      color: Color(json['color'] ?? 0xFF000000),
      difficulty: json['difficulty'] ?? '',
      totalLessons: json['totalLessons'] ?? 0,
      estimatedHours: json['estimatedHours'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color.value,
      'difficulty': difficulty,
      'totalLessons': totalLessons,
      'estimatedHours': estimatedHours,
      'tags': tags,
      'order': order,
    };
  }
}

class CourseModule {
  final String id;
  final String name;
  final String description;
  final List<String> lessonIds;
  final int order;

  const CourseModule({
    required this.id,
    required this.name,
    required this.description,
    required this.lessonIds,
    this.order = 0,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      lessonIds: List<String>.from(json['lessonIds'] ?? []),
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'lessonIds': lessonIds,
      'order': order,
    };
  }
}
