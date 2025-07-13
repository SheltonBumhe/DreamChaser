import 'package:flutter/material.dart';
import '../models/ai_insight_model.dart';
import '../models/ai_recommendation_model.dart';
import '../models/grade_prediction_model.dart';

class AIProvider extends ChangeNotifier {
  List<AIInsight> _insights = [];
  List<AIRecommendation> _recommendations = [];
  List<GradePrediction> _gradePredictions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AIInsight> get insights => _insights;
  List<AIRecommendation> get recommendations => _recommendations;
  List<GradePrediction> get gradePredictions => _gradePredictions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AIProvider() {
    _generateMockInsights();
  }

  Future<void> _generateMockInsights() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate AI processing
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock AI insights
      _insights = [
        AIInsight(
          id: '1',
          type: InsightType.academic,
          title: 'Strong Performance in Algorithms',
          description: 'Your performance in Advanced Algorithms is exceptional. You\'re consistently scoring above 90% on assignments.',
          confidence: 0.95,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          actionable: true,
        ),
        AIInsight(
          id: '2',
          type: InsightType.trend,
          title: 'Improving Study Pattern',
          description: 'Your study consistency has improved by 25% this semester compared to last semester.',
          confidence: 0.87,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          actionable: false,
        ),
        AIInsight(
          id: '3',
          type: InsightType.warning,
          title: 'Database Assignment Due Soon',
          description: 'You have a high-priority assignment due in 3 days that requires significant time investment.',
          confidence: 0.92,
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          actionable: true,
        ),
      ];

      // Mock AI recommendations
      _recommendations = [
        AIRecommendation(
          id: '1',
          type: RecommendationType.study,
          title: 'Focus on Database Systems',
          description: 'Spend 2-3 hours daily on Database Systems to improve your current grade from 88% to 92%.',
          priority: RecommendationPriority.high,
          estimatedTime: const Duration(hours: 2),
          expectedOutcome: 'Grade improvement of 4%',
        ),
        AIRecommendation(
          id: '2',
          type: RecommendationType.timeManagement,
          title: 'Optimize Study Schedule',
          description: 'Study during your peak productivity hours (9-11 AM) for better retention.',
          priority: RecommendationPriority.medium,
          estimatedTime: const Duration(minutes: 30),
          expectedOutcome: 'Improved learning efficiency',
        ),
        AIRecommendation(
          id: '3',
          type: RecommendationType.career,
          title: 'Apply for Summer Internships',
          description: 'Your strong performance in algorithms makes you a great candidate for software engineering internships.',
          priority: RecommendationPriority.high,
          estimatedTime: const Duration(hours: 4),
          expectedOutcome: 'Career opportunities',
        ),
      ];

      // Mock grade predictions
      _gradePredictions = [
        GradePrediction(
          courseId: '1',
          courseName: 'Advanced Algorithms',
          currentGrade: 92.5,
          predictedGrade: 94.2,
          confidence: 0.88,
          factors: ['Strong assignment performance', 'Active participation'],
        ),
        GradePrediction(
          courseId: '2',
          courseName: 'Database Systems',
          currentGrade: 88.0,
          predictedGrade: 91.5,
          confidence: 0.75,
          factors: ['Need to improve on final project', 'Good quiz scores'],
        ),
        GradePrediction(
          courseId: '3',
          courseName: 'Software Engineering',
          currentGrade: 95.2,
          predictedGrade: 96.8,
          confidence: 0.92,
          factors: ['Excellent team collaboration', 'Strong technical skills'],
        ),
        GradePrediction(
          courseId: '4',
          courseName: 'Machine Learning',
          currentGrade: 91.8,
          predictedGrade: 93.5,
          confidence: 0.85,
          factors: ['Consistent performance', 'Good understanding of concepts'],
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to generate insights: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateInsights(List<dynamic> academicData) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate AI analysis
      await Future.delayed(const Duration(seconds: 3));
      
      // In a real app, this would call an AI service
      // For now, we'll just regenerate mock data
      await _generateMockInsights();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to generate insights: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPersonalizedRecommendations() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate AI recommendation generation
      await Future.delayed(const Duration(seconds: 2));
      
      // Add new recommendations based on current data
      _recommendations.addAll([
        AIRecommendation(
          id: '4',
          type: RecommendationType.assignment,
          title: 'Prioritize Dynamic Programming Project',
          description: 'This assignment has the highest impact on your final grade. Start working on it today.',
          priority: RecommendationPriority.high,
          estimatedTime: const Duration(hours: 6),
          expectedOutcome: 'Maintain high grade in Algorithms',
        ),
        AIRecommendation(
          id: '5',
          type: RecommendationType.study,
          title: 'Review Neural Network Concepts',
          description: 'Spend 1 hour reviewing neural network fundamentals before the next assignment.',
          priority: RecommendationPriority.medium,
          estimatedTime: const Duration(hours: 1),
          expectedOutcome: 'Better understanding for upcoming assignment',
        ),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to get recommendations: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> predictGrades(List<dynamic> courseData) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate AI grade prediction
      await Future.delayed(const Duration(seconds: 2));
      
      // Update grade predictions based on current performance
      for (int i = 0; i < _gradePredictions.length; i++) {
        final prediction = _gradePredictions[i];
        final newPredictedGrade = prediction.predictedGrade + (DateTime.now().millisecond % 5 - 2) * 0.1;
        final newConfidence = (prediction.confidence + 0.05).clamp(0.0, 1.0);
        _gradePredictions[i] = prediction.copyWith(
          predictedGrade: newPredictedGrade,
          confidence: newConfidence,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to predict grades: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AIInsight> getInsightsByType(InsightType type) {
    return _insights.where((insight) => insight.type == type).toList();
  }

  List<AIRecommendation> getRecommendationsByType(RecommendationType type) {
    return _recommendations.where((rec) => rec.type == type).toList();
  }

  List<AIRecommendation> getHighPriorityRecommendations() {
    return _recommendations
        .where((rec) => rec.priority == RecommendationPriority.high)
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 