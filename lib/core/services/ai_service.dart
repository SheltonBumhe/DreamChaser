import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/job_opportunity_model.dart';
import '../models/course_model.dart';
import '../models/skill_model.dart';
import '../models/ai_insight_model.dart';
import '../models/ai_recommendation_model.dart';
import '../models/job_opportunity_model.dart';
import 'api_config.dart';
import 'http_client.dart';

class AIService {
  static final ApiHttpClient _httpClient = ApiHttpClient();

  // AI-powered skill matching
  static Future<double> calculateSkillMatch(
    List<String> jobSkills,
    List<Course> courses,
    List<Skill> userSkills,
  ) async {
    try {
      if (!ApiConfig.isAIAvailable) {
        return _calculateBasicSkillMatch(jobSkills, courses, userSkills);
      }

      final prompt = _buildSkillMatchPrompt(jobSkills, courses, userSkills);
      final response = await _callOpenAI(prompt);
      
      final matchScore = _parseSkillMatchResponse(response);
      return matchScore;
    } catch (e) {
      debugPrint('AI skill matching error: ${e.toString()}');
      return _calculateBasicSkillMatch(jobSkills, courses, userSkills);
    }
  }

  // Generate personalized job recommendations
  static Future<List<AIRecommendation>> generateJobRecommendations({
    required List<Course> courses,
    required List<Skill> userSkills,
    required List<JobOpportunity> availableJobs,
    String? preferredLocation,
    JobType? preferredType,
    int limit = 10,
  }) async {
    try {
      if (!ApiConfig.isAIAvailable) {
        return _generateMockRecommendations(availableJobs, limit);
      }

      final prompt = _buildRecommendationPrompt(
        courses: courses,
        userSkills: userSkills,
        availableJobs: availableJobs,
        preferredLocation: preferredLocation,
        preferredType: preferredType,
      );

      final response = await _callOpenAI(prompt);
      return _parseRecommendationResponse(response, availableJobs);
    } catch (e) {
      debugPrint('AI recommendation error: ${e.toString()}');
      return _generateMockRecommendations(availableJobs, limit);
    }
  }

  // Generate career insights
  static Future<List<AIInsight>> generateCareerInsights({
    required List<Course> courses,
    required List<Skill> userSkills,
    required List<JobOpportunity> recentJobs,
  }) async {
    try {
      if (!ApiConfig.isAIAvailable) {
        return _generateMockInsights();
      }

      final prompt = _buildInsightPrompt(
        courses: courses,
        userSkills: userSkills,
        recentJobs: recentJobs,
      );

      final response = await _callOpenAI(prompt);
      return _parseInsightResponse(response);
    } catch (e) {
      debugPrint('AI insight error: ${e.toString()}');
      return _generateMockInsights();
    }
  }

  // Analyze skill gaps
  static Future<List<String>> analyzeSkillGaps({
    required List<String> targetJobSkills,
    required List<Course> courses,
    required List<Skill> userSkills,
  }) async {
    try {
      if (!ApiConfig.isAIAvailable) {
        return _analyzeBasicSkillGaps(targetJobSkills, courses, userSkills);
      }

      final prompt = _buildSkillGapPrompt(
        targetJobSkills: targetJobSkills,
        courses: courses,
        userSkills: userSkills,
      );

      final response = await _callOpenAI(prompt);
      return _parseSkillGapResponse(response);
    } catch (e) {
      debugPrint('AI skill gap analysis error: ${e.toString()}');
      return _analyzeBasicSkillGaps(targetJobSkills, courses, userSkills);
    }
  }

  // Call OpenAI API
  static Future<String> _callOpenAI(String prompt) async {
    final url = '${ApiConfig.openaiBaseUrl}/chat/completions';
    final body = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': 'You are a career advisor and job matching expert. Provide accurate, helpful responses for job seekers.',
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'max_tokens': 1000,
      'temperature': 0.7,
    };

    final response = await _httpClient.post(
      url,
      service: 'openai',
      body: body,
    );

    final data = json.decode(response.body);
    return data['choices'][0]['message']['content'];
  }

  // Build skill match prompt
  static String _buildSkillMatchPrompt(
    List<String> jobSkills,
    List<Course> courses,
    List<Skill> userSkills,
  ) {
    final courseNames = courses.map((c) => '${c.name} (${c.code})').join(', ');
    final userSkillNames = userSkills.map((s) => s.name).join(', ');

    return '''
Analyze the skill match between a job and a candidate:

Job Skills Required: ${jobSkills.join(', ')}

Candidate's Courses: $courseNames
Candidate's Skills: $userSkillNames

Calculate a skill match percentage (0-100) based on:
1. Direct skill matches
2. Related skills from courses
3. Transferable skills

Return only a number between 0 and 100.
''';
  }

  // Build recommendation prompt
  static String _buildRecommendationPrompt({
    required List<Course> courses,
    required List<Skill> userSkills,
    required List<JobOpportunity> availableJobs,
    String? preferredLocation,
    JobType? preferredType,
  }) {
    final courseNames = courses.map((c) => '${c.name} (${c.code})').join(', ');
    final userSkillNames = userSkills.map((s) => s.name).join(', ');
    final jobTitles = availableJobs.map((j) => '${j.title} at ${j.company}').join(', ');

    return '''
Recommend the best jobs for this candidate:

Candidate's Courses: $courseNames
Candidate's Skills: $userSkillNames
Preferred Location: ${preferredLocation ?? 'Any'}
Preferred Job Type: ${preferredType?.name ?? 'Any'}

Available Jobs: $jobTitles

Rank the top 10 jobs by:
1. Skill match
2. Location preference
3. Job type preference
4. Company reputation
5. Salary competitiveness

Return a JSON array with job IDs and reasoning.
''';
  }

  // Build insight prompt
  static String _buildInsightPrompt({
    required List<Course> courses,
    required List<Skill> userSkills,
    required List<JobOpportunity> recentJobs,
  }) {
    final courseNames = courses.map((c) => '${c.name} (${c.code})').join(', ');
    final userSkillNames = userSkills.map((s) => s.name).join(', ');
    final jobTitles = recentJobs.map((j) => j.title).join(', ');

    return '''
Generate career insights for this candidate:

Courses: $courseNames
Skills: $userSkillNames
Recent Job Market: $jobTitles

Provide insights on:
1. Market demand for their skills
2. Salary expectations
3. Career growth opportunities
4. Recommended skill development
5. Industry trends

Return insights as a JSON array.
''';
  }

  // Build skill gap prompt
  static String _buildSkillGapPrompt({
    required List<String> targetJobSkills,
    required List<Course> courses,
    required List<Skill> userSkills,
  }) {
    final courseNames = courses.map((c) => '${c.name} (${c.code})').join(', ');
    final userSkillNames = userSkills.map((s) => s.name).join(', ');

    return '''
Identify skill gaps for this target job:

Target Job Skills: ${targetJobSkills.join(', ')}
Candidate's Courses: $courseNames
Candidate's Skills: $userSkillNames

List the specific skills the candidate needs to develop to qualify for this job.

Return as a JSON array of skill names.
''';
  }

  // Parse skill match response
  static double _parseSkillMatchResponse(String response) {
    try {
      final cleanResponse = response.trim();
      final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(cleanResponse);
      if (match != null) {
        final score = double.tryParse(match.group(1) ?? '0') ?? 0.0;
        return score.clamp(0.0, 100.0);
      }
    } catch (e) {
      debugPrint('Error parsing skill match response: $e');
    }
    return 0.0;
  }

  // Parse recommendation response
  static List<AIRecommendation> _parseRecommendationResponse(
    String response,
    List<JobOpportunity> availableJobs,
  ) {
    try {
      final data = json.decode(response);
      final recommendations = <AIRecommendation>[];

      for (final item in data) {
        final jobId = item['jobId'];
        final job = availableJobs.firstWhere(
          (j) => j.id == jobId,
          orElse: () => availableJobs.first,
        );

        recommendations.add(AIRecommendation(
          id: item['jobId'] ?? 'rec_${recommendations.length}',
          type: RecommendationType.career,
          title: 'Job Recommendation',
          description: item['reasoning'] ?? 'AI recommendation',
          priority: RecommendationPriority.high,
          estimatedTime: const Duration(hours: 1),
          expectedOutcome: 'Apply to this position',
          reasoning: item['reasoning'] ?? 'AI recommendation',
          confidence: item['confidence'] ?? 0.8,
          matchScore: item['matchScore'] ?? 0.0,
        ));
      }

      return recommendations;
    } catch (e) {
      debugPrint('Error parsing recommendation response: $e');
      return _generateMockRecommendations(availableJobs, 5);
    }
  }

  // Parse insight response
  static List<AIInsight> _parseInsightResponse(String response) {
    try {
      final data = json.decode(response);
      final insights = <AIInsight>[];

      for (final item in data) {
        insights.add(AIInsight(
          id: item['id'] ?? 'insight_${insights.length}',
          type: InsightType.recommendation,
          title: item['title'] ?? 'Career Insight',
          description: item['description'] ?? '',
          confidence: item['confidence'] ?? 0.8,
          timestamp: DateTime.now(),
          actionable: item['actionable'] ?? true,
        ));
      }

      return insights;
    } catch (e) {
      debugPrint('Error parsing insight response: $e');
      return _generateMockInsights();
    }
  }

  // Parse skill gap response
  static List<String> _parseSkillGapResponse(String response) {
    try {
      final data = json.decode(response);
      return List<String>.from(data);
    } catch (e) {
      debugPrint('Error parsing skill gap response: $e');
      return [];
    }
  }

  // Basic skill matching (fallback)
  static double _calculateBasicSkillMatch(
    List<String> jobSkills,
    List<Course> courses,
    List<Skill> userSkills,
  ) {
    if (jobSkills.isEmpty) return 0.0;

    final Set<String> availableSkills = <String>{};
    
    // Add skills from courses
    for (final course in courses) {
      final courseSkills = _extractSkillsFromCourse(course);
      availableSkills.addAll(courseSkills);
    }

    // Add user skills
    availableSkills.addAll(userSkills.map((s) => s.name.toLowerCase()));

    // Calculate match
    final jobSkillsLower = jobSkills.map((s) => s.toLowerCase()).toSet();
    final matchedSkills = availableSkills.intersection(jobSkillsLower);
    
    return (matchedSkills.length / jobSkillsLower.length) * 100;
  }

  // Extract skills from course
  static List<String> _extractSkillsFromCourse(Course course) {
    final skills = <String>{};
    final courseText = '${course.name} ${course.code}'.toLowerCase();
    
    final skillPatterns = [
      'python', 'java', 'javascript', 'react', 'angular', 'vue',
      'sql', 'database', 'algorithm', 'data structure', 'machine learning',
      'ai', 'web development', 'mobile development', 'cloud computing',
    ];

    for (final skill in skillPatterns) {
      if (courseText.contains(skill)) {
        skills.add(skill);
      }
    }

    return skills.toList();
  }

  // Basic skill gap analysis (fallback)
  static List<String> _analyzeBasicSkillGaps(
    List<String> targetJobSkills,
    List<Course> courses,
    List<Skill> userSkills,
  ) {
    final Set<String> availableSkills = <String>{};
    
    // Add skills from courses
    for (final course in courses) {
      final courseSkills = _extractSkillsFromCourse(course);
      availableSkills.addAll(courseSkills);
    }

    // Add user skills
    availableSkills.addAll(userSkills.map((s) => s.name.toLowerCase()));

    // Find gaps
    final targetSkillsLower = targetJobSkills.map((s) => s.toLowerCase()).toSet();
    final gaps = targetSkillsLower.difference(availableSkills);

    return gaps.toList();
  }

  // Mock recommendations
  static List<AIRecommendation> _generateMockRecommendations(
    List<JobOpportunity> availableJobs,
    int limit,
  ) {
    return availableJobs.take(limit).map((job) => AIRecommendation(
      id: 'rec_${job.id}',
      type: RecommendationType.career,
      title: 'Job Recommendation',
      description: 'Based on your skills and experience',
      priority: RecommendationPriority.high,
      estimatedTime: const Duration(hours: 1),
      expectedOutcome: 'Apply to this position',
      reasoning: 'Based on your skills and experience',
      confidence: 0.8,
      matchScore: 75.0,
    )).toList();
  }

  // Mock insights
  static List<AIInsight> _generateMockInsights() {
    return [
      AIInsight(
        id: 'insight_1',
        type: InsightType.recommendation,
        title: 'High Demand for Your Skills',
        description: 'Your technical skills are in high demand in the current job market.',
        confidence: 0.9,
        timestamp: DateTime.now(),
        actionable: true,
      ),
      AIInsight(
        id: 'insight_2',
        type: InsightType.recommendation,
        title: 'Competitive Salary Range',
        description: 'Based on your skills, you can expect a salary range of \$80,000 - \$120,000.',
        confidence: 0.8,
        timestamp: DateTime.now(),
        actionable: true,
      ),
      AIInsight(
        id: 'insight_3',
        type: InsightType.recommendation,
        title: 'Career Growth Opportunities',
        description: 'Consider focusing on machine learning and cloud technologies for career advancement.',
        confidence: 0.7,
        timestamp: DateTime.now(),
        actionable: true,
      ),
    ];
  }
} 