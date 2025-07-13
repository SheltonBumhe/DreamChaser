import 'package:flutter/material.dart';

enum SkillCategory {
  programming,
  ai,
  database,
  analytics,
  architecture,
  infrastructure,
  framework,
  other,
}
enum SkillLevel { beginner, intermediate, advanced, expert }

class Skill {
  final String id;
  final String name;
  final SkillCategory category;
  final SkillLevel level;

  Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String,
      name: json['name'] as String,
      category: SkillCategory.values.firstWhere(
        (e) => e.toString() == 'SkillCategory.${json['category']}',
      ),
      level: SkillLevel.values.firstWhere(
        (e) => e.toString() == 'SkillLevel.${json['level']}',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.toString().split('.').last,
      'level': level.toString().split('.').last,
    };
  }

  Skill copyWith({
    String? id,
    String? name,
    SkillCategory? category,
    SkillLevel? level,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      level: level ?? this.level,
    );
  }

  Color get levelColor {
    switch (level) {
      case SkillLevel.beginner:
        return Colors.green;
      case SkillLevel.intermediate:
        return Colors.blue;
      case SkillLevel.advanced:
        return Colors.orange;
      case SkillLevel.expert:
        return Colors.red;
    }
  }

  String get levelString {
    switch (level) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
    }
  }

  String get categoryString {
    switch (category) {
      case SkillCategory.programming:
        return 'Programming';
      case SkillCategory.framework:
        return 'Framework';
      case SkillCategory.ai:
        return 'AI/ML';
      case SkillCategory.database:
        return 'Database';
      case SkillCategory.analytics:
        return 'Analytics';
      case SkillCategory.architecture:
        return 'Architecture';
      case SkillCategory.infrastructure:
        return 'Infrastructure';
      case SkillCategory.other:
        return 'Other';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case SkillCategory.programming:
        return Icons.code;
      case SkillCategory.framework:
        return Icons.library_books;
      case SkillCategory.ai:
        return Icons.psychology;
      case SkillCategory.database:
        return Icons.storage;
      case SkillCategory.analytics:
        return Icons.analytics;
      case SkillCategory.architecture:
        return Icons.architecture;
      case SkillCategory.infrastructure:
        return Icons.cloud;
      case SkillCategory.other:
        return Icons.category;
    }
  }
} 