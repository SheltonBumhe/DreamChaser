import 'package:flutter/material.dart';

class Internship {
  final String id;
  final String title;
  final String company;
  final String location;
  final String duration;
  final String stipend;
  final String description;
  final List<String> requirements;
  final List<String> skills;
  final DateTime startDate;
  final DateTime applicationDeadline;
  final double matchScore;

  Internship({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.duration,
    required this.stipend,
    required this.description,
    required this.requirements,
    required this.skills,
    required this.startDate,
    required this.applicationDeadline,
    required this.matchScore,
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      duration: json['duration'] as String,
      stipend: json['stipend'] as String,
      description: json['description'] as String,
      requirements: List<String>.from(json['requirements'] as List),
      skills: List<String>.from(json['skills'] as List),
      startDate: DateTime.parse(json['startDate'] as String),
      applicationDeadline: DateTime.parse(json['applicationDeadline'] as String),
      matchScore: (json['matchScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'duration': duration,
      'stipend': stipend,
      'description': description,
      'requirements': requirements,
      'skills': skills,
      'startDate': startDate.toIso8601String(),
      'applicationDeadline': applicationDeadline.toIso8601String(),
      'matchScore': matchScore,
    };
  }

  Internship copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? duration,
    String? stipend,
    String? description,
    List<String>? requirements,
    List<String>? skills,
    DateTime? startDate,
    DateTime? applicationDeadline,
    double? matchScore,
  }) {
    return Internship(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      duration: duration ?? this.duration,
      stipend: stipend ?? this.stipend,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      skills: skills ?? this.skills,
      startDate: startDate ?? this.startDate,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      matchScore: matchScore ?? this.matchScore,
    );
  }

  bool get isUrgent {
    final now = DateTime.now();
    final daysUntilDeadline = applicationDeadline.difference(now).inDays;
    return daysUntilDeadline <= 7;
  }

  String get timeUntilDeadline {
    final now = DateTime.now();
    final difference = applicationDeadline.difference(now);
    
    if (difference.isNegative) {
      return 'Deadline passed';
    }
    
    final days = difference.inDays;
    if (days > 0) {
      return '$days day${days == 1 ? '' : 's'} left';
    } else {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} left';
    }
  }

  String get startDateString {
    final now = DateTime.now();
    final difference = startDate.difference(now);
    
    if (difference.isNegative) {
      return 'Started ${difference.inDays.abs()} days ago';
    }
    
    final days = difference.inDays;
    if (days > 0) {
      return 'Starts in $days day${days == 1 ? '' : 's'}';
    } else {
      return 'Starting soon';
    }
  }

  Color get matchScoreColor {
    if (matchScore >= 0.8) return Colors.green;
    if (matchScore >= 0.6) return Colors.orange;
    return Colors.red;
  }
} 