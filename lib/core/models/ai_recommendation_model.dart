import 'package:flutter/material.dart';

enum RecommendationType { study, timeManagement, assignment, career, health }
enum RecommendationPriority { low, medium, high }

class AIRecommendation {
  final String id;
  final RecommendationType type;
  final String title;
  final String description;
  final RecommendationPriority priority;
  final Duration estimatedTime;
  final String expectedOutcome;

  AIRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedTime,
    required this.expectedOutcome,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'] as String,
      type: RecommendationType.values.firstWhere(
        (e) => e.toString() == 'RecommendationType.${json['type']}',
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      priority: RecommendationPriority.values.firstWhere(
        (e) => e.toString() == 'RecommendationPriority.${json['priority']}',
      ),
      estimatedTime: Duration(milliseconds: json['estimatedTime'] as int),
      expectedOutcome: json['expectedOutcome'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'priority': priority.toString().split('.').last,
      'estimatedTime': estimatedTime.inMilliseconds,
      'expectedOutcome': expectedOutcome,
    };
  }

  AIRecommendation copyWith({
    String? id,
    RecommendationType? type,
    String? title,
    String? description,
    RecommendationPriority? priority,
    Duration? estimatedTime,
    String? expectedOutcome,
  }) {
    return AIRecommendation(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      expectedOutcome: expectedOutcome ?? this.expectedOutcome,
    );
  }

  String get estimatedTimeString {
    final hours = estimatedTime.inHours;
    final minutes = estimatedTime.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '$hours hr $minutes min';
    } else if (hours > 0) {
      return '$hours hr';
    } else {
      return '$minutes min';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case RecommendationPriority.high:
        return Colors.red;
      case RecommendationPriority.medium:
        return Colors.orange;
      case RecommendationPriority.low:
        return Colors.green;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case RecommendationType.study:
        return Icons.book;
      case RecommendationType.timeManagement:
        return Icons.schedule;
      case RecommendationType.assignment:
        return Icons.assignment;
      case RecommendationType.career:
        return Icons.work;
      case RecommendationType.health:
        return Icons.favorite;
    }
  }

  Color get typeColor {
    switch (type) {
      case RecommendationType.study:
        return Colors.blue;
      case RecommendationType.timeManagement:
        return Colors.green;
      case RecommendationType.assignment:
        return Colors.orange;
      case RecommendationType.career:
        return Colors.purple;
      case RecommendationType.health:
        return Colors.red;
    }
  }
} 