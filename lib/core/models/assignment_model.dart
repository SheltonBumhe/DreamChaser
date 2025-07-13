import 'package:flutter/material.dart';

enum AssignmentPriority { low, medium, high }

class Assignment {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final int points;
  final bool isCompleted;
  final AssignmentPriority priority;

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.points,
    required this.isCompleted,
    required this.priority,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      points: json['points'] as int,
      isCompleted: json['isCompleted'] as bool,
      priority: AssignmentPriority.values.firstWhere(
        (e) => e.toString() == 'AssignmentPriority.${json['priority']}',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'points': points,
      'isCompleted': isCompleted,
      'priority': priority.toString().split('.').last,
    };
  }

  Assignment copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? points,
    bool? isCompleted,
    AssignmentPriority? priority,
  }) {
    return Assignment(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate) && !isCompleted;
  bool get isDueSoon {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference <= 3 && difference >= 0 && !isCompleted;
  }
  
  Duration get timeUntilDue => dueDate.difference(DateTime.now());
  String get timeUntilDueString {
    final duration = timeUntilDue;
    if (duration.isNegative) {
      final days = duration.inDays.abs();
      return '$days day${days == 1 ? '' : 's'} overdue';
    }
    
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    
    if (days > 0) {
      return '$days day${days == 1 ? '' : 's'} remaining';
    } else if (hours > 0) {
      return '$hours hour${hours == 1 ? '' : 's'} remaining';
    } else {
      return 'Due soon';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case AssignmentPriority.high:
        return Colors.red;
      case AssignmentPriority.medium:
        return Colors.orange;
      case AssignmentPriority.low:
        return Colors.green;
    }
  }

  String get priorityString {
    switch (priority) {
      case AssignmentPriority.high:
        return 'High';
      case AssignmentPriority.medium:
        return 'Medium';
      case AssignmentPriority.low:
        return 'Low';
    }
  }
} 