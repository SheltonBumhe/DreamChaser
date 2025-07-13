import 'package:flutter/material.dart';

class GradePrediction {
  final String courseId;
  final String courseName;
  final double currentGrade;
  final double predictedGrade;
  final double confidence;
  final List<String> factors;

  GradePrediction({
    required this.courseId,
    required this.courseName,
    required this.currentGrade,
    required this.predictedGrade,
    required this.confidence,
    required this.factors,
  });

  factory GradePrediction.fromJson(Map<String, dynamic> json) {
    return GradePrediction(
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String,
      currentGrade: (json['currentGrade'] as num).toDouble(),
      predictedGrade: (json['predictedGrade'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      factors: List<String>.from(json['factors'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'currentGrade': currentGrade,
      'predictedGrade': predictedGrade,
      'confidence': confidence,
      'factors': factors,
    };
  }

  GradePrediction copyWith({
    String? courseId,
    String? courseName,
    double? currentGrade,
    double? predictedGrade,
    double? confidence,
    List<String>? factors,
  }) {
    return GradePrediction(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      currentGrade: currentGrade ?? this.currentGrade,
      predictedGrade: predictedGrade ?? this.predictedGrade,
      confidence: confidence ?? this.confidence,
      factors: factors ?? this.factors,
    );
  }

  double get gradeChange => predictedGrade - currentGrade;
  bool get isImproving => gradeChange > 0;
  bool get isDeclining => gradeChange < 0;
  
  String get gradeChangeString {
    final change = gradeChange;
    if (change > 0) {
      return '+${change.toStringAsFixed(1)}%';
    } else if (change < 0) {
      return '${change.toStringAsFixed(1)}%';
    } else {
      return 'No change';
    }
  }

  Color get confidenceColor {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String get confidenceString => '${(confidence * 100).toInt()}% confident';
} 