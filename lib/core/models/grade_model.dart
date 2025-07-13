class Grade {
  final String assignmentId;
  final String assignmentName;
  final double score;
  final int totalPoints;
  final double percentage;
  final String courseName;
  final String semester;
  final int credits;
  final double grade;
  final double gradePoints;

  Grade({
    required this.assignmentId,
    required this.assignmentName,
    required this.score,
    required this.totalPoints,
    required this.percentage,
    required this.courseName,
    required this.semester,
    required this.credits,
    required this.grade,
    required this.gradePoints,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    final score = (json['score'] as num?)?.toDouble() ?? 0.0;
    final totalPoints = json['totalPoints'] as int? ?? 1;
    return Grade(
      assignmentId: json['assignmentId']?.toString() ?? '',
      assignmentName: json['assignmentName'] ?? '',
      score: score,
      totalPoints: totalPoints,
      percentage: totalPoints > 0 ? (score / totalPoints) : 0.0,
      courseName: json['courseName'] ?? '',
      semester: json['semester'] ?? '',
      credits: json['credits'] ?? 0,
      grade: (json['grade'] as num?)?.toDouble() ?? 0.0,
      gradePoints: (json['gradePoints'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'assignmentName': assignmentName,
      'score': score,
      'totalPoints': totalPoints,
      'percentage': percentage,
      'courseName': courseName,
      'semester': semester,
      'credits': credits,
      'grade': grade,
      'gradePoints': gradePoints,
    };
  }

  Grade copyWith({
    String? assignmentId,
    String? assignmentName,
    double? score,
    int? totalPoints,
    double? percentage,
    String? courseName,
    String? semester,
    int? credits,
    double? grade,
    double? gradePoints,
  }) {
    return Grade(
      assignmentId: assignmentId ?? this.assignmentId,
      assignmentName: assignmentName ?? this.assignmentName,
      score: score ?? this.score,
      totalPoints: totalPoints ?? this.totalPoints,
      percentage: percentage ?? this.percentage,
      courseName: courseName ?? this.courseName,
      semester: semester ?? this.semester,
      credits: credits ?? this.credits,
      grade: grade ?? this.grade,
      gradePoints: gradePoints ?? this.gradePoints,
    );
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

  double get qualityPoints => gradePoints * credits;
} 