class Course {
  final String id;
  final String name;
  final String code;
  final String instructor;
  final int credits;
  final double grade;
  final int assignments;
  final int completedAssignments;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.instructor,
    required this.credits,
    required this.grade,
    required this.assignments,
    required this.completedAssignments,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      instructor: json['instructor'] as String,
      credits: json['credits'] as int,
      grade: (json['grade'] as num).toDouble(),
      assignments: json['assignments'] as int,
      completedAssignments: json['completedAssignments'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'instructor': instructor,
      'credits': credits,
      'grade': grade,
      'assignments': assignments,
      'completedAssignments': completedAssignments,
    };
  }

  Course copyWith({
    String? id,
    String? name,
    String? code,
    String? instructor,
    int? credits,
    double? grade,
    int? assignments,
    int? completedAssignments,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      instructor: instructor ?? this.instructor,
      credits: credits ?? this.credits,
      grade: grade ?? this.grade,
      assignments: assignments ?? this.assignments,
      completedAssignments: completedAssignments ?? this.completedAssignments,
    );
  }

  double get assignmentProgress => assignments > 0 ? (completedAssignments / assignments) * 100 : 0.0;
  int get remainingAssignments => assignments - completedAssignments;
  String get letterGrade {
    if (grade >= 93) return 'A';
    if (grade >= 90) return 'A-';
    if (grade >= 87) return 'B+';
    if (grade >= 83) return 'B';
    if (grade >= 80) return 'B-';
    if (grade >= 77) return 'C+';
    if (grade >= 73) return 'C';
    if (grade >= 70) return 'C-';
    if (grade >= 67) return 'D+';
    if (grade >= 63) return 'D';
    if (grade >= 60) return 'D-';
    return 'F';
  }
} 