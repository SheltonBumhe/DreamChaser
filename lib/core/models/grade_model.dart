class Grade {
  final String courseId;
  final String courseName;
  final double grade;
  final double gradePoints;
  final int credits;
  final String semester;

  Grade({
    required this.courseId,
    required this.courseName,
    required this.grade,
    required this.gradePoints,
    required this.credits,
    required this.semester,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String,
      grade: (json['grade'] as num).toDouble(),
      gradePoints: (json['gradePoints'] as num).toDouble(),
      credits: json['credits'] as int,
      semester: json['semester'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'grade': grade,
      'gradePoints': gradePoints,
      'credits': credits,
      'semester': semester,
    };
  }

  Grade copyWith({
    String? courseId,
    String? courseName,
    double? grade,
    double? gradePoints,
    int? credits,
    String? semester,
  }) {
    return Grade(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      grade: grade ?? this.grade,
      gradePoints: gradePoints ?? this.gradePoints,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
    );
  }

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

  double get qualityPoints => gradePoints * credits;
} 