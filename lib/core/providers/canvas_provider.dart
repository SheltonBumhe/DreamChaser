import 'package:flutter/foundation.dart';
import '../models/canvas_models.dart';
import '../models/skill_model.dart';
import '../services/canvas_integration_service.dart';
import '../services/http_client.dart';

class CanvasProvider extends ChangeNotifier {
  final CanvasIntegrationService _canvasService;
  
  List<Course> _courses = [];
  List<Assignment> _assignments = [];
  List<Grade> _grades = [];
  List<Skill> _canvasSkills = [];
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;

  CanvasProvider() : _canvasService = CanvasIntegrationService(ApiHttpClient());

  // Getters
  List<Course> get courses => _courses;
  List<Assignment> get assignments => _assignments;
  List<Grade> get grades => _grades;
  List<Skill> get canvasSkills => _canvasSkills;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;
  
  // Additional getters for dashboard
  double get overallGPA {
    if (_courses.isEmpty) return 0.0;
    
    double totalGradePoints = 0.0;
    int totalCredits = 0;
    
    for (final course in _courses) {
      if (course.grade.isNotEmpty) {
        final gradePoints = course.gradeValue;
        final credits = course.credits;
        totalGradePoints += gradePoints * credits;
        totalCredits += credits;
      }
    }
    
    return totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;
  }
  
  List<Assignment> get upcomingAssignments {
    final now = DateTime.now();
    return _assignments
        .where((assignment) => 
            assignment.dueDate.isAfter(now) && 
            !assignment.isCompleted)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Initialize Canvas integration
  Future<void> initializeCanvas() async {
    try {
      _setLoading(true);
      _clearError();

      // Check if user has consented to Canvas integration
      final hasConsent = await _canvasService.hasUserConsent();
      if (!hasConsent) {
        _setError('Canvas integration requires user consent');
        return;
      }

      // Fetch courses
      _courses = await _canvasService.getCourses();
      
      // Extract skills from courses
      _canvasSkills = _extractSkillsFromCourses(_courses);

      // Fetch assignments and grades for each course
      for (final course in _courses) {
        try {
          final assignments = await _canvasService.getAssignments(course.id);
          final grades = await _canvasService.getGrades(course.id);
          
          _assignments.addAll(assignments);
          _grades.addAll(grades);
        } catch (e) {
          debugPrint('Error fetching data for course ${course.id}: $e');
        }
      }

      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to initialize Canvas: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Extract skills from Canvas courses
  List<Skill> _extractSkillsFromCourses(List<Course> courses) {
    final List<Skill> skills = [];
    final Set<String> addedSkills = <String>{};

    // Skill mapping from Canvas courses
    const Map<String, List<String>> courseSkillMapping = {
      'CS101': ['Programming', 'Computer Science', 'Problem Solving'],
      'CS201': ['Data Structures', 'Algorithms', 'Programming'],
      'CS301': ['Advanced Algorithms', 'Data Structures', 'Problem Solving'],
      'CS302': ['Database Design', 'SQL', 'Data Modeling'],
      'CS303': ['Software Engineering', 'Project Management', 'Team Collaboration'],
      'CS401': ['Machine Learning', 'Python', 'Statistics', 'Data Analysis'],
      'MATH201': ['Calculus', 'Mathematics', 'Analytical Thinking'],
      'ENG101': ['Communication', 'Writing', 'Critical Thinking'],
      'PHYS101': ['Physics', 'Problem Solving', 'Laboratory Skills'],
    };

    for (final course in courses) {
      final courseSkills = courseSkillMapping[course.code] ?? [];
      
      for (final skillName in courseSkills) {
        if (!addedSkills.contains(skillName)) {
          skills.add(Skill(
            id: skillName.toLowerCase().replaceAll(' ', '_'),
            name: skillName,
            category: _getSkillCategory(skillName),
            level: _getSkillLevel(course.grade),
          ));
          addedSkills.add(skillName);
        }
      }
    }

    return skills;
  }

  // Calculate skill level based on course grade
  SkillLevel _getSkillLevel(String grade) {
    if (grade.isEmpty) return SkillLevel.beginner;
    
    final gradeUpper = grade.toUpperCase();
    if (gradeUpper.contains('A')) return SkillLevel.expert;
    if (gradeUpper.contains('B')) return SkillLevel.advanced;
    if (gradeUpper.contains('C')) return SkillLevel.intermediate;
    return SkillLevel.beginner;
  }

  // Determine skill category
  SkillCategory _getSkillCategory(String skillName) {
    final skill = skillName.toLowerCase();
    
    if (skill.contains('python') || skill.contains('java') || skill.contains('javascript')) {
      return SkillCategory.programming;
    }
    if (skill.contains('machine learning') || skill.contains('ai')) {
      return SkillCategory.ai;
    }
    if (skill.contains('sql') || skill.contains('database')) {
      return SkillCategory.database;
    }
    if (skill.contains('data') || skill.contains('analysis')) {
      return SkillCategory.analytics;
    }
    if (skill.contains('design') || skill.contains('architecture')) {
      return SkillCategory.architecture;
    }
    if (skill.contains('cloud') || skill.contains('infrastructure')) {
      return SkillCategory.infrastructure;
    }
    if (skill.contains('framework') || skill.contains('react') || skill.contains('angular')) {
      return SkillCategory.framework;
    }
    
    return SkillCategory.other;
  }

  // Match job requirements with Canvas skills
  double calculateSkillMatch(List<String> jobSkills) {
    if (jobSkills.isEmpty || _courses.isEmpty) return 0.0;

    final Set<String> availableSkills = <String>{};
    
    for (final course in _courses) {
      final courseSkills = _getCourseSkills(course.code);
      availableSkills.addAll(courseSkills.map((s) => s.toLowerCase()));
    }

    final jobSkillsLower = jobSkills.map((s) => s.toLowerCase()).toSet();
    final matchedSkills = availableSkills.intersection(jobSkillsLower);
    
    return matchedSkills.length / jobSkillsLower.length;
  }

  // Get related courses for a job
  List<String> getRelatedCourses(List<String> jobSkills) {
    final List<String> relatedCourses = [];
    final jobSkillsLower = jobSkills.map((s) => s.toLowerCase()).toSet();

    const Map<String, List<String>> courseSkillMapping = {
      'CS101': ['Programming', 'Computer Science', 'Problem Solving'],
      'CS201': ['Data Structures', 'Algorithms', 'Programming'],
      'CS301': ['Advanced Algorithms', 'Data Structures', 'Problem Solving'],
      'CS302': ['Database Design', 'SQL', 'Data Modeling'],
      'CS303': ['Software Engineering', 'Project Management', 'Team Collaboration'],
      'CS401': ['Machine Learning', 'Python', 'Statistics', 'Data Analysis'],
      'MATH201': ['Calculus', 'Mathematics', 'Analytical Thinking'],
      'ENG101': ['Communication', 'Writing', 'Critical Thinking'],
      'PHYS101': ['Physics', 'Problem Solving', 'Laboratory Skills'],
    };

    for (final entry in courseSkillMapping.entries) {
      final courseSkills = entry.value.map((s) => s.toLowerCase()).toSet();
      if (courseSkills.intersection(jobSkillsLower).isNotEmpty) {
        relatedCourses.add(entry.key);
      }
    }

    return relatedCourses;
  }

  // Get skills for a specific course
  List<String> _getCourseSkills(String courseCode) {
    const Map<String, List<String>> courseSkillMapping = {
      'CS101': ['Programming', 'Computer Science', 'Problem Solving'],
      'CS201': ['Data Structures', 'Algorithms', 'Programming'],
      'CS301': ['Advanced Algorithms', 'Data Structures', 'Problem Solving'],
      'CS302': ['Database Design', 'SQL', 'Data Modeling'],
      'CS303': ['Software Engineering', 'Project Management', 'Team Collaboration'],
      'CS401': ['Machine Learning', 'Python', 'Statistics', 'Data Analysis'],
      'MATH201': ['Calculus', 'Mathematics', 'Analytical Thinking'],
      'ENG101': ['Communication', 'Writing', 'Critical Thinking'],
      'PHYS101': ['Physics', 'Problem Solving', 'Laboratory Skills'],
    };

    return courseSkillMapping[courseCode] ?? [];
  }

  // Get skills for a specific course (public method)
  List<String> getCourseSkills(String courseCode) {
    return _getCourseSkills(courseCode);
  }

  // Sync Canvas data
  Future<void> syncCanvasData() async {
    try {
      _setLoading(true);
      _clearError();

      await initializeCanvas();
    } catch (e) {
      _setError('Failed to sync Canvas data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Request Canvas access
  Future<void> requestCanvasAccess() async {
    try {
      await _canvasService.requestCanvasAccess();
      await initializeCanvas();
    } catch (e) {
      _setError('Failed to request Canvas access: ${e.toString()}');
    }
  }

  // Revoke Canvas access
  Future<void> revokeCanvasAccess() async {
    try {
      await _canvasService.revokeCanvasAccess();
      _courses.clear();
      _assignments.clear();
      _grades.clear();
      _canvasSkills.clear();
      _isConnected = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to revoke Canvas access: ${e.toString()}');
    }
  }

  // Test Canvas connection
  Future<bool> testCanvasConnection() async {
    try {
      await _canvasService.getCourses();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Refresh data
  Future<void> refresh() async {
    await initializeCanvas();
  }
} 