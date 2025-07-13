import 'package:flutter/material.dart';

enum JobType { fullTime, partTime, contract, internship }
enum SecurityLevel { verified, trusted, unverified, flagged }
enum ApplicationMethod { direct, external, email, phone }

class JobOpportunity {
  final String id;
  final String title;
  final String company;
  final String location;
  final JobType type;
  final String salary;
  final String description;
  final List<String> requirements;
  final List<String> skills;
  final DateTime postedDate;
  final DateTime applicationDeadline;
  final double matchScore;
  
  // Security and verification fields
  final SecurityLevel securityLevel;
  final bool isVerifiedCompany;
  final bool hasDirectApplication;
  final String? applicationUrl;
  final String? applicationEmail;
  final String? applicationPhone;
  final ApplicationMethod applicationMethod;
  final List<String> scamIndicators;
  final bool isScam;
  
  // Canvas integration fields
  final List<String> relatedCanvasCourses;
  final List<String> requiredCanvasSkills;
  final double canvasSkillMatch;

  JobOpportunity({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.salary,
    required this.description,
    required this.requirements,
    required this.skills,
    required this.postedDate,
    required this.applicationDeadline,
    required this.matchScore,
    this.securityLevel = SecurityLevel.unverified,
    this.isVerifiedCompany = false,
    this.hasDirectApplication = false,
    this.applicationUrl,
    this.applicationEmail,
    this.applicationPhone,
    this.applicationMethod = ApplicationMethod.external,
    this.scamIndicators = const [],
    this.isScam = false,
    this.relatedCanvasCourses = const [],
    this.requiredCanvasSkills = const [],
    this.canvasSkillMatch = 0.0,
  });

  factory JobOpportunity.fromJson(Map<String, dynamic> json) {
    return JobOpportunity(
      id: json['id'] as String,
      title: json['title'] as String,
      company: json['company'] as String,
      location: json['location'] as String,
      type: JobType.values.firstWhere(
        (e) => e.toString() == 'JobType.${json['type']}',
      ),
      salary: json['salary'] as String,
      description: json['description'] as String,
      requirements: List<String>.from(json['requirements'] as List),
      skills: List<String>.from(json['skills'] as List),
      postedDate: DateTime.parse(json['postedDate'] as String),
      applicationDeadline: DateTime.parse(json['applicationDeadline'] as String),
      matchScore: (json['matchScore'] as num).toDouble(),
      securityLevel: SecurityLevel.values.firstWhere(
        (e) => e.toString() == 'SecurityLevel.${json['securityLevel'] ?? 'unverified'}',
      ),
      isVerifiedCompany: json['isVerifiedCompany'] as bool? ?? false,
      hasDirectApplication: json['hasDirectApplication'] as bool? ?? false,
      applicationUrl: json['applicationUrl'] as String?,
      applicationEmail: json['applicationEmail'] as String?,
      applicationPhone: json['applicationPhone'] as String?,
      applicationMethod: ApplicationMethod.values.firstWhere(
        (e) => e.toString() == 'ApplicationMethod.${json['applicationMethod'] ?? 'external'}',
      ),
      scamIndicators: List<String>.from(json['scamIndicators'] as List? ?? []),
      isScam: json['isScam'] as bool? ?? false,
      relatedCanvasCourses: List<String>.from(json['relatedCanvasCourses'] as List? ?? []),
      requiredCanvasSkills: List<String>.from(json['requiredCanvasSkills'] as List? ?? []),
      canvasSkillMatch: (json['canvasSkillMatch'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'type': type.toString().split('.').last,
      'salary': salary,
      'description': description,
      'requirements': requirements,
      'skills': skills,
      'postedDate': postedDate.toIso8601String(),
      'applicationDeadline': applicationDeadline.toIso8601String(),
      'matchScore': matchScore,
      'securityLevel': securityLevel.toString().split('.').last,
      'isVerifiedCompany': isVerifiedCompany,
      'hasDirectApplication': hasDirectApplication,
      'applicationUrl': applicationUrl,
      'applicationEmail': applicationEmail,
      'applicationPhone': applicationPhone,
      'applicationMethod': applicationMethod.toString().split('.').last,
      'scamIndicators': scamIndicators,
      'isScam': isScam,
      'relatedCanvasCourses': relatedCanvasCourses,
      'requiredCanvasSkills': requiredCanvasSkills,
      'canvasSkillMatch': canvasSkillMatch,
    };
  }

  JobOpportunity copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    JobType? type,
    String? salary,
    String? description,
    List<String>? requirements,
    List<String>? skills,
    DateTime? postedDate,
    DateTime? applicationDeadline,
    double? matchScore,
    SecurityLevel? securityLevel,
    bool? isVerifiedCompany,
    bool? hasDirectApplication,
    String? applicationUrl,
    String? applicationEmail,
    String? applicationPhone,
    ApplicationMethod? applicationMethod,
    List<String>? scamIndicators,
    bool? isScam,
    List<String>? relatedCanvasCourses,
    List<String>? requiredCanvasSkills,
    double? canvasSkillMatch,
  }) {
    return JobOpportunity(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      type: type ?? this.type,
      salary: salary ?? this.salary,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      skills: skills ?? this.skills,
      postedDate: postedDate ?? this.postedDate,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      matchScore: matchScore ?? this.matchScore,
      securityLevel: securityLevel ?? this.securityLevel,
      isVerifiedCompany: isVerifiedCompany ?? this.isVerifiedCompany,
      hasDirectApplication: hasDirectApplication ?? this.hasDirectApplication,
      applicationUrl: applicationUrl ?? this.applicationUrl,
      applicationEmail: applicationEmail ?? this.applicationEmail,
      applicationPhone: applicationPhone ?? this.applicationPhone,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      scamIndicators: scamIndicators ?? this.scamIndicators,
      isScam: isScam ?? this.isScam,
      relatedCanvasCourses: relatedCanvasCourses ?? this.relatedCanvasCourses,
      requiredCanvasSkills: requiredCanvasSkills ?? this.requiredCanvasSkills,
      canvasSkillMatch: canvasSkillMatch ?? this.canvasSkillMatch,
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

  String get postedTimeAgo {
    final now = DateTime.now();
    final difference = now.difference(postedDate);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'Just posted';
    }
  }

  Color get matchScoreColor {
    if (matchScore >= 0.8) return Colors.green;
    if (matchScore >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color get overallMatchScoreColor {
    if (overallMatchScore >= 0.8) return Colors.green;
    if (overallMatchScore >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String get typeString {
    switch (type) {
      case JobType.fullTime:
        return 'Full Time';
      case JobType.partTime:
        return 'Part Time';
      case JobType.contract:
        return 'Contract';
      case JobType.internship:
        return 'Internship';
    }
  }

  // Security and verification methods
  Color get securityLevelColor {
    switch (securityLevel) {
      case SecurityLevel.verified:
        return Colors.green;
      case SecurityLevel.trusted:
        return Colors.blue;
      case SecurityLevel.unverified:
        return Colors.orange;
      case SecurityLevel.flagged:
        return Colors.red;
    }
  }

  String get securityLevelString {
    switch (securityLevel) {
      case SecurityLevel.verified:
        return 'Verified';
      case SecurityLevel.trusted:
        return 'Trusted';
      case SecurityLevel.unverified:
        return 'Unverified';
      case SecurityLevel.flagged:
        return 'Flagged';
    }
  }

  String get applicationMethodString {
    switch (applicationMethod) {
      case ApplicationMethod.direct:
        return 'Direct Application';
      case ApplicationMethod.external:
        return 'External Link';
      case ApplicationMethod.email:
        return 'Email Application';
      case ApplicationMethod.phone:
        return 'Phone Application';
    }
  }

  bool get isSecure {
    return securityLevel == SecurityLevel.verified || 
           securityLevel == SecurityLevel.trusted;
  }

  bool get hasValidApplicationMethod {
    return applicationUrl != null || 
           applicationEmail != null || 
           applicationPhone != null;
  }

  String? get primaryApplicationLink {
    if (applicationUrl != null) return applicationUrl;
    if (applicationEmail != null) return 'mailto:$applicationEmail';
    if (applicationPhone != null) return 'tel:$applicationPhone';
    return null;
  }

  // Canvas integration methods
  bool get hasCanvasIntegration {
    return relatedCanvasCourses.isNotEmpty || requiredCanvasSkills.isNotEmpty;
  }

  double get overallMatchScore {
    return (matchScore + canvasSkillMatch) / 2;
  }
} 