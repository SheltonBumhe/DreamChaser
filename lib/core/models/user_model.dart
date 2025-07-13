class User {
  final String id;
  final String email;
  final String name;
  final String avatar;
  final String institution;
  final String major;
  final int year;
  final double gpa;
  final int creditsCompleted;
  final int totalCredits;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.avatar,
    required this.institution,
    required this.major,
    required this.year,
    required this.gpa,
    required this.creditsCompleted,
    required this.totalCredits,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String,
      institution: json['institution'] as String,
      major: json['major'] as String,
      year: json['year'] as int,
      gpa: (json['gpa'] as num).toDouble(),
      creditsCompleted: json['creditsCompleted'] as int,
      totalCredits: json['totalCredits'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'institution': institution,
      'major': major,
      'year': year,
      'gpa': gpa,
      'creditsCompleted': creditsCompleted,
      'totalCredits': totalCredits,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    String? institution,
    String? major,
    int? year,
    double? gpa,
    int? creditsCompleted,
    int? totalCredits,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      institution: institution ?? this.institution,
      major: major ?? this.major,
      year: year ?? this.year,
      gpa: gpa ?? this.gpa,
      creditsCompleted: creditsCompleted ?? this.creditsCompleted,
      totalCredits: totalCredits ?? this.totalCredits,
    );
  }

  double get progressPercentage => totalCredits > 0 ? (creditsCompleted / totalCredits) * 100 : 0.0;
  int get remainingCredits => totalCredits - creditsCompleted;
} 