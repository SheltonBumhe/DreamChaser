import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/job_opportunity_model.dart';
import '../models/internship_model.dart';
import '../models/skill_model.dart';
import '../models/course_model.dart';
import '../models/ai_recommendation_model.dart';
import '../services/job_search_service.dart';
import '../services/ai_service.dart';
import '../services/canvas_integration_service.dart';
import 'package:provider/provider.dart';
import '../providers/canvas_provider.dart';

class CareerProvider extends ChangeNotifier {
  List<JobOpportunity> _jobOpportunities = [];
  List<Internship> _internships = [];
  List<Skill> _skills = [];
  List<Skill> _userSkills = [];
  List<Course> _canvasCourses = [];
  List<AIRecommendation> _aiRecommendations = [];
  bool _isLoading = false;
  String? _error;
  bool _isCanvasConnected = false;

  // Getters
  List<JobOpportunity> get jobOpportunities => _jobOpportunities;
  List<Internship> get internships => _internships;
  List<Skill> get skills => _skills;
  List<Skill> get userSkills => _userSkills;
  List<Course> get canvasCourses => _canvasCourses;
  List<AIRecommendation> get aiRecommendations => _aiRecommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCanvasConnected => _isCanvasConnected;

  CareerProvider() {
    _loadSecureData();
  }

  Future<void> _loadSecureData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load jobs with real API integration
      _jobOpportunities = await JobSearchService.searchJobs();
      
      // Load Canvas courses for integration
      await _loadCanvasCourses();
      _isCanvasConnected = _canvasCourses.isNotEmpty;

      // Mock internships (keeping existing data for now)
      _internships = [
        Internship(
          id: '1',
          title: 'Software Engineering Intern',
          company: 'Apple',
          location: 'Cupertino, CA',
          duration: '12 weeks',
          stipend: '\$8,000/month',
          description: 'Work on real projects that impact millions of users.',
          requirements: [
            'Currently pursuing Computer Science degree',
            'Strong programming fundamentals',
            'Experience with iOS development preferred',
            'Available for 12 weeks',
          ],
          skills: ['iOS Development', 'Swift', 'Objective-C', 'Mobile Development'],
          startDate: DateTime.now().add(const Duration(days: 60)),
          applicationDeadline: DateTime.now().add(const Duration(days: 15)),
          matchScore: 0.90,
        ),
        Internship(
          id: '2',
          title: 'Machine Learning Intern',
          company: 'Amazon',
          location: 'Seattle, WA',
          duration: '10 weeks',
          stipend: '\$7,500/month',
          description: 'Develop ML models for recommendation systems.',
          requirements: [
            'Currently pursuing Computer Science or related degree',
            'Experience with Python and ML libraries',
            'Understanding of algorithms and data structures',
            'Strong analytical skills',
          ],
          skills: ['Machine Learning', 'Python', 'TensorFlow', 'Data Analysis'],
          startDate: DateTime.now().add(const Duration(days: 45)),
          applicationDeadline: DateTime.now().add(const Duration(days: 10)),
          matchScore: 0.87,
        ),
        Internship(
          id: '3',
          title: 'Data Science Intern',
          company: 'Facebook',
          location: 'Menlo Park, CA',
          duration: '12 weeks',
          stipend: '\$8,200/month',
          description: 'Analyze large datasets to drive business decisions.',
          requirements: [
            'Currently pursuing degree in Data Science, Statistics, or related field',
            'Experience with SQL and Python',
            'Understanding of statistical analysis',
            'Experience with data visualization tools',
          ],
          skills: ['Data Analysis', 'SQL', 'Python', 'Statistics'],
          startDate: DateTime.now().add(const Duration(days: 75)),
          applicationDeadline: DateTime.now().add(const Duration(days: 20)),
          matchScore: 0.83,
        ),
      ];

      // Mock skills
      _skills = [
        Skill(id: '1', name: 'Python', category: SkillCategory.programming, level: SkillLevel.intermediate),
        Skill(id: '2', name: 'Java', category: SkillCategory.programming, level: SkillLevel.beginner),
        Skill(id: '3', name: 'JavaScript', category: SkillCategory.programming, level: SkillLevel.intermediate),
        Skill(id: '4', name: 'React', category: SkillCategory.framework, level: SkillLevel.beginner),
        Skill(id: '5', name: 'Machine Learning', category: SkillCategory.ai, level: SkillLevel.intermediate),
        Skill(id: '6', name: 'SQL', category: SkillCategory.database, level: SkillLevel.intermediate),
        Skill(id: '7', name: 'Data Analysis', category: SkillCategory.analytics, level: SkillLevel.intermediate),
        Skill(id: '8', name: 'System Design', category: SkillCategory.architecture, level: SkillLevel.beginner),
        Skill(id: '9', name: 'Cloud Computing', category: SkillCategory.infrastructure, level: SkillLevel.beginner),
        Skill(id: '10', name: 'Statistics', category: SkillCategory.analytics, level: SkillLevel.intermediate),
      ];

      // Mock user skills
      _userSkills = [
        Skill(id: '1', name: 'Python', category: SkillCategory.programming, level: SkillLevel.intermediate),
        Skill(id: '5', name: 'Machine Learning', category: SkillCategory.ai, level: SkillLevel.intermediate),
        Skill(id: '6', name: 'SQL', category: SkillCategory.database, level: SkillLevel.intermediate),
        Skill(id: '7', name: 'Data Analysis', category: SkillCategory.analytics, level: SkillLevel.intermediate),
        Skill(id: '10', name: 'Statistics', category: SkillCategory.analytics, level: SkillLevel.intermediate),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load secure career data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCanvasCourses() async {
    try {
      // For now, we'll use mock Canvas courses since we can't access Provider context here
      _canvasCourses = [
        Course(
          id: '1',
          name: 'Introduction to Computer Science',
          code: 'CS101',
          instructor: 'Dr. Smith',
          semester: 'Fall 2024',
          credits: 3,
          grade: 'A-',
          assignments: [],
        ),
        Course(
          id: '2',
          name: 'Data Structures and Algorithms',
          code: 'CS201',
          instructor: 'Dr. Johnson',
          semester: 'Fall 2024',
          credits: 4,
          grade: 'B+',
          assignments: [],
        ),
      ];
    } catch (e) {
      debugPrint('Error loading Canvas courses: $e');
      _canvasCourses = [];
    }
  }

  Future<void> searchJobs({
    String? query,
    JobType? type,
    String? location,
    double? minSalary,
    double? maxSalary,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use real job search service
      _jobOpportunities = await JobSearchService.searchJobs(
        query: query,
        type: type,
        location: location,
        minSalary: minSalary,
        maxSalary: maxSalary,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to search jobs: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyForJob(JobOpportunity job, Map<String, dynamic> applicationData) async {
    try {
      // For now, simulate job application
      // In production, this would integrate with job application APIs
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // Update job status or add to applied jobs list
      notifyListeners();
    } catch (e) {
      _error = 'Failed to apply for job: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> connectCanvas() async {
    try {
      await _refreshCanvasData();
      _isCanvasConnected = _canvasCourses.isNotEmpty;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to connect to Canvas: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> addUserSkill(Skill skill) async {
    if (!_userSkills.any((s) => s.id == skill.id)) {
      _userSkills.add(skill);
      notifyListeners();
    }
  }

  Future<void> removeUserSkill(String skillId) async {
    _userSkills.removeWhere((skill) => skill.id == skillId);
    notifyListeners();
  }

  Future<void> updateSkillLevel(String skillId, SkillLevel level) async {
    final index = _userSkills.indexWhere((skill) => skill.id == skillId);
    if (index != -1) {
      _userSkills[index] = _userSkills[index].copyWith(level: level);
      notifyListeners();
    }
  }

  List<JobOpportunity> getRecommendedJobs() {
    return _jobOpportunities
        .where((job) => job.overallMatchScore > 0.8 && job.isSecure)
        .toList()
      ..sort((a, b) => b.overallMatchScore.compareTo(a.overallMatchScore));
  }

  List<JobOpportunity> getSecureJobs() {
    return _jobOpportunities
        .where((job) => job.isSecure && !job.isScam)
        .toList();
  }

  List<JobOpportunity> getJobsWithCanvasIntegration() {
    return _jobOpportunities
        .where((job) => job.hasCanvasIntegration)
        .toList();
  }

  List<Internship> getRecommendedInternships() {
    return _internships
        .where((internship) => internship.matchScore > 0.8)
        .toList()
      ..sort((a, b) => b.matchScore.compareTo(a.matchScore));
  }

  List<Skill> getSkillsByCategory(SkillCategory category) {
    return _skills.where((skill) => skill.category == category).toList();
  }

  List<JobOpportunity> getJobsBySecurityLevel(SecurityLevel level) {
    return _jobOpportunities
        .where((job) => job.securityLevel == level)
        .toList();
  }

  List<JobOpportunity> getJobsByApplicationMethod(ApplicationMethod method) {
    return _jobOpportunities
        .where((job) => job.applicationMethod == method)
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refreshData() async {
    await _loadSecureData();
  }

  // AI-powered features
  Future<void> generateAIRecommendations() async {
    try {
      _aiRecommendations = await AIService.generateJobRecommendations(
        courses: _canvasCourses,
        userSkills: _userSkills,
        availableJobs: _jobOpportunities,
        limit: 10,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to generate AI recommendations: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<double> calculateSkillMatch(JobOpportunity job) async {
    try {
      return await AIService.calculateSkillMatch(
        job.skills,
        _canvasCourses,
        _userSkills,
      );
    } catch (e) {
      _error = 'Failed to calculate skill match: ${e.toString()}';
      return 0.0;
    }
  }

  Future<List<String>> analyzeSkillGaps(JobOpportunity targetJob) async {
    try {
      return await AIService.analyzeSkillGaps(
        targetJobSkills: targetJob.skills,
        courses: _canvasCourses,
        userSkills: _userSkills,
      );
    } catch (e) {
      _error = 'Failed to analyze skill gaps: ${e.toString()}';
      return [];
    }
  }

  Future<void> _refreshCanvasData() async {
    try {
      // For now, we'll use mock Canvas courses since we can't access Provider context here
      _canvasCourses = [
        Course(
          id: '1',
          name: 'Introduction to Computer Science',
          code: 'CS101',
          instructor: 'Dr. Smith',
          semester: 'Fall 2024',
          credits: 3,
          grade: 'A-',
          assignments: [],
        ),
        Course(
          id: '2',
          name: 'Data Structures and Algorithms',
          code: 'CS201',
          instructor: 'Dr. Johnson',
          semester: 'Fall 2024',
          credits: 4,
          grade: 'B+',
          assignments: [],
        ),
      ];
    } catch (e) {
      debugPrint('Error refreshing Canvas data: $e');
    }
  }

  Future<void> _updateCanvasCourses() async {
    try {
      // For now, we'll use mock Canvas courses since we can't access Provider context here
      _canvasCourses = [
        Course(
          id: '1',
          name: 'Introduction to Computer Science',
          code: 'CS101',
          instructor: 'Dr. Smith',
          semester: 'Fall 2024',
          credits: 3,
          grade: 'A-',
          assignments: [],
        ),
        Course(
          id: '2',
          name: 'Data Structures and Algorithms',
          code: 'CS201',
          instructor: 'Dr. Johnson',
          semester: 'Fall 2024',
          credits: 4,
          grade: 'B+',
          assignments: [],
        ),
      ];
    } catch (e) {
      debugPrint('Error updating Canvas courses: $e');
    }
  }

  Future<void> _testCanvasConnection() async {
    try {
      // For now, we'll simulate a successful connection test
      debugPrint('Canvas connection test: Success');
    } catch (e) {
      debugPrint('Canvas connection test error: $e');
    }
  }
} 