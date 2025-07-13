import 'package:flutter/material.dart';

class Course {
  final String id;
  final String name;
  final String code;
  final String description;
  final String instructor;
  final String semester;
  final int credits;
  final String grade;
  final List<Assignment> assignments;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.instructor,
    required this.semester,
    required this.credits,
    required this.grade,
    required this.assignments,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      code: json['course_code'] ?? '',
      description: json['description'] ?? '',
      instructor: json['teachers']?[0]?['display_name'] ?? 'Unknown',
      semester: json['term']?['name'] ?? '',
      credits: json['credits'] ?? 0,
      grade: json['grades']?['current_grade'] ?? '',
      assignments: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'instructor': instructor,
      'semester': semester,
      'credits': credits,
      'grade': grade,
      'assignments': assignments.map((a) => a.toJson()).toList(),
    };
  }

  Course copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? instructor,
    String? semester,
    int? credits,
    String? grade,
    List<Assignment>? assignments,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      instructor: instructor ?? this.instructor,
      semester: semester ?? this.semester,
      credits: credits ?? this.credits,
      grade: grade ?? this.grade,
      assignments: assignments ?? this.assignments,
    );
  }

  String get displayName => '$code: $name';
  
  Color get gradeColor {
    if (grade.isEmpty) return Colors.grey;
    
    final gradeUpper = grade.toUpperCase();
    if (gradeUpper.contains('A')) return Colors.green;
    if (gradeUpper.contains('B')) return Colors.blue;
    if (gradeUpper.contains('C')) return Colors.orange;
    if (gradeUpper.contains('D')) return Colors.red;
    return Colors.grey;
  }

  double get gradePercentage {
    if (grade.isEmpty) return 0.0;
    
    final gradeUpper = grade.toUpperCase();
    if (gradeUpper.contains('A+')) return 97.0;
    if (gradeUpper.contains('A')) return 93.0;
    if (gradeUpper.contains('A-')) return 90.0;
    if (gradeUpper.contains('B+')) return 87.0;
    if (gradeUpper.contains('B')) return 83.0;
    if (gradeUpper.contains('B-')) return 80.0;
    if (gradeUpper.contains('C+')) return 77.0;
    if (gradeUpper.contains('C')) return 73.0;
    if (gradeUpper.contains('C-')) return 70.0;
    if (gradeUpper.contains('D+')) return 67.0;
    if (gradeUpper.contains('D')) return 63.0;
    if (gradeUpper.contains('D-')) return 60.0;
    return 0.0;
  }
}

class Assignment {
  final String id;
  final String name;
  final String description;
  final DateTime dueDate;
  final int points;
  final double? grade;
  final String status;

  Assignment({
    required this.id,
    required this.name,
    required this.description,
    required this.dueDate,
    required this.points,
    this.grade,
    required this.status,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['due_at'] != null 
          ? DateTime.parse(json['due_at']) 
          : DateTime.now().add(Duration(days: 7)),
      points: json['points_possible'] ?? 0,
      grade: json['score'] != null ? (json['score'] as num).toDouble() : null,
      status: json['submission_types']?.isNotEmpty == true ? 'submitted' : 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'points': points,
      'grade': grade,
      'status': status,
    };
  }

  Assignment copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? dueDate,
    int? points,
    double? grade,
    String? status,
  }) {
    return Assignment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      points: points ?? this.points,
      grade: grade ?? this.grade,
      status: status ?? this.status,
    );
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate);
  
  bool get isSubmitted => status == 'submitted';
  
  bool get isPending => status == 'pending';
  
  String get timeUntilDue {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.isNegative) {
      return 'Overdue';
    }
    
    final days = difference.inDays;
    if (days > 0) {
      return '$days day${days == 1 ? '' : 's'} left';
    } else {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} left';
    }
  }

  Color get statusColor {
    if (isOverdue) return Colors.red;
    if (isSubmitted) return Colors.green;
    return Colors.orange;
  }

  double get gradePercentage {
    if (grade == null || points == 0) return 0.0;
    return (grade! / points) * 100;
  }
}

class Grade {
  final String assignmentId;
  final String assignmentName;
  final double score;
  final int totalPoints;
  final double percentage;

  Grade({
    required this.assignmentId,
    required this.assignmentName,
    required this.score,
    required this.totalPoints,
    required this.percentage,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    final score = (json['score'] as num?)?.toDouble() ?? 0.0;
    final totalPoints = json['total_points'] as int? ?? 1;
    
    return Grade(
      assignmentId: json['assignment_id'].toString(),
      assignmentName: json['assignment_name'] ?? '',
      score: score,
      totalPoints: totalPoints,
      percentage: totalPoints > 0 ? (score / totalPoints) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'assignmentName': assignmentName,
      'score': score,
      'totalPoints': totalPoints,
      'percentage': percentage,
    };
  }

  Grade copyWith({
    String? assignmentId,
    String? assignmentName,
    double? score,
    int? totalPoints,
    double? percentage,
  }) {
    return Grade(
      assignmentId: assignmentId ?? this.assignmentId,
      assignmentName: assignmentName ?? this.assignmentName,
      score: score ?? this.score,
      totalPoints: totalPoints ?? this.totalPoints,
      percentage: percentage ?? this.percentage,
    );
  }

  Color get gradeColor {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.blue;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }

  String get letterGrade {
    if (percentage >= 93) return 'A';
    if (percentage >= 90) return 'A-';
    if (percentage >= 87) return 'B+';
    if (percentage >= 83) return 'B';
    if (percentage >= 80) return 'B-';
    if (percentage >= 77) return 'C+';
    if (percentage >= 73) return 'C';
    if (percentage >= 70) return 'C-';
    if (percentage >= 67) return 'D+';
    if (percentage >= 63) return 'D';
    if (percentage >= 60) return 'D-';
    return 'F';
  }
} 