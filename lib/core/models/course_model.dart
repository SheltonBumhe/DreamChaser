import 'package:dream_chaser/core/models/canvas_models.dart';

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
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String? ?? '',
      instructor: json['instructor'] as String,
      semester: json['semester'] as String? ?? '',
      credits: json['credits'] as int,
      grade: json['grade'] as String? ?? '',
      assignments: (json['assignments'] as List<dynamic>? ?? [])
          .map((a) => Assignment.fromJson(a as Map<String, dynamic>))
          .toList(),
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

  String get letterGrade {
    if (grade.isEmpty) return 'N/A';
    return grade.toUpperCase();
  }
} 