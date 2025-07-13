import 'package:flutter/material.dart';

enum InsightType { academic, trend, warning, achievement, recommendation }
enum AIInsightType { market, salary, growth, skills, industry }

class AIInsight {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final double confidence;
  final DateTime timestamp;
  final bool actionable;

  AIInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.timestamp,
    required this.actionable,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      id: json['id'] as String,
      type: InsightType.values.firstWhere(
        (e) => e.toString() == 'InsightType.${json['type']}',
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      actionable: json['actionable'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'actionable': actionable,
    };
  }

  AIInsight copyWith({
    String? id,
    InsightType? type,
    String? title,
    String? description,
    double? confidence,
    DateTime? timestamp,
    bool? actionable,
  }) {
    return AIInsight(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      actionable: actionable ?? this.actionable,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Color get typeColor {
    switch (type) {
      case InsightType.academic:
        return Colors.blue;
      case InsightType.trend:
        return Colors.green;
      case InsightType.warning:
        return Colors.orange;
      case InsightType.achievement:
        return Colors.purple;
      case InsightType.recommendation:
        return Colors.teal;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case InsightType.academic:
        return Icons.school;
      case InsightType.trend:
        return Icons.trending_up;
      case InsightType.warning:
        return Icons.warning;
      case InsightType.achievement:
        return Icons.emoji_events;
      case InsightType.recommendation:
        return Icons.lightbulb;
    }
  }
} 