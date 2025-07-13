import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/assignment_model.dart';
import '../models/grade_model.dart';
import '../models/skill_model.dart';
import '../services/canvas_integration_service.dart';

class CanvasProvider extends ChangeNotifier {
  List<Course> _courses = [];
  List<Assignment> _assignments = [];
  List<Grade> _grades = [];
  List<Skill> _canvasSkills = [];
  bool _isLoading = false;
  bool _isConnected = false;
  String? _error;

  // Getters
  List<Course> get courses => _courses;
  List<Assignment> get assignments => _assignments;
  List<Grade> get grades => _grades;
  List<Skill> get canvasSkills => _canvasSkills;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get error => _error;

  // Computed properties
  double get overallGPA {
    if (_grades.isEmpty) return 0.0;
    double totalPoints = 0.0;
    double totalCredits = 0.0;
    
    for (var grade in _grades) {
      totalPoints += grade.gradePoints * grade.credits;
      totalCredits += grade.credits;
    }
    
    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
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

  List<Assignment> get overdueAssignments {
    final now = DateTime.now();
    return _assignments
        .where((assignment) => 
            assignment.dueDate.isBefore(now) && 
            !assignment.isCompleted)
        .toList();
  }

  List<Skill> get skillsByCategory {
    final Map<SkillCategory, List<Skill>> categorized = {};
    for (final skill in _canvasSkills) {
      categorized.putIfAbsent(skill.category, () => []).add(skill);
    }
    return categorized.values.expand((skills) => skills).toList();
  }

  CanvasProvider() {
    _loadCanvasData();
  }

  Future<void> _loadCanvasData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch courses from Canvas
      _courses = await CanvasIntegrationService.fetchUserCourses();
      
      // Extract skills from courses
      _canvasSkills = CanvasIntegrationService.extractSkillsFromCourses(_courses);
      
      // Fetch assignments and grades for each course
      final List<Assignment> allAssignments = [];
      final List<Grade> allGrades = [];

      for (final course in _courses) {
        final assignments = await CanvasIntegrationService.fetchCourseAssignments(course.id);
        final grades = await CanvasIntegrationService.fetchCourseGrades(course.id);
        
        allAssignments.addAll(assignments);
        allGrades.addAll(grades);
      }

      _assignments = allAssignments;
      _grades = allGrades;
      _isConnected = true;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load Canvas data: ${e.toString()}';
      _isLoading = false;
      _isConnected = false;
      notifyListeners();
    }
  }

  Future<void> connectToCanvas() async {
    _isLoading = true;
    notifyListeners();

    try {
      await CanvasIntegrationService.syncCanvasData();
      await _loadCanvasData();
    } catch (e) {
      _error = 'Failed to connect to Canvas: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await _loadCanvasData();
  }

  Future<void> addAssignment(Assignment assignment) async {
    _assignments.add(assignment);
    notifyListeners();
  }

  Future<void> updateAssignment(Assignment assignment) async {
    final index = _assignments.indexWhere((a) => a.id == assignment.id);
    if (index != -1) {
      _assignments[index] = assignment;
      notifyListeners();
    }
  }

  Future<void> deleteAssignment(String assignmentId) async {
    _assignments.removeWhere((a) => a.id == assignmentId);
    notifyListeners();
  }

  Future<void> markAssignmentComplete(String assignmentId) async {
    final index = _assignments.indexWhere((a) => a.id == assignmentId);
    if (index != -1) {
      _assignments[index] = _assignments[index].copyWith(isCompleted: true);
      notifyListeners();
    }
  }

  List<Assignment> getAssignmentsForCourse(String courseId) {
    return _assignments.where((a) => a.courseId == courseId).toList();
  }

  Course? getCourseById(String courseId) {
    try {
      return _courses.firstWhere((c) => c.id == courseId);
    } catch (e) {
      return null;
    }
  }

  List<Skill> getSkillsByCategory(SkillCategory category) {
    return _canvasSkills.where((skill) => skill.category == category).toList();
  }

  List<Skill> getSkillsByLevel(SkillLevel level) {
    return _canvasSkills.where((skill) => skill.level == level).toList();
  }

  double calculateJobSkillMatch(List<String> jobSkills) {
    return CanvasIntegrationService.calculateSkillMatch(jobSkills, _courses);
  }

  List<String> getRelatedCoursesForJob(List<String> jobSkills) {
    return CanvasIntegrationService.getRelatedCourses(jobSkills);
  }

  List<Course> getCoursesBySkill(String skillName) {
    return _courses.where((course) {
      final courseSkills = CanvasIntegrationService.courseSkillMapping[course.code] ?? [];
      return courseSkills.any((skill) => 
          skill.toLowerCase().contains(skillName.toLowerCase()));
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get courses that are relevant to a specific job
  List<Course> getRelevantCoursesForJob(List<String> jobSkills) {
    final relevantCourses = <Course>[];
    final jobSkillsLower = jobSkills.map((s) => s.toLowerCase()).toSet();

    for (final course in _courses) {
      final courseSkills = CanvasIntegrationService.courseSkillMapping[course.code] ?? [];
      final courseSkillsLower = courseSkills.map((s) => s.toLowerCase()).toSet();
      
      if (courseSkillsLower.intersection(jobSkillsLower).isNotEmpty) {
        relevantCourses.add(course);
      }
    }

    return relevantCourses;
  }

  // Get skills that need improvement for a job
  List<Skill> getSkillsNeedingImprovement(List<String> jobSkills) {
    final jobSkillsLower = jobSkills.map((s) => s.toLowerCase()).toSet();
    final List<Skill> needsImprovement = [];

    for (final skill in _canvasSkills) {
      if (jobSkillsLower.contains(skill.name.toLowerCase()) && 
          skill.level == SkillLevel.beginner) {
        needsImprovement.add(skill);
      }
    }

    return needsImprovement;
  }

  // Get missing skills for a job
  List<String> getMissingSkillsForJob(List<String> jobSkills) {
    final availableSkills = _canvasSkills.map((s) => s.name.toLowerCase()).toSet();
    final jobSkillsLower = jobSkills.map((s) => s.toLowerCase()).toSet();
    
    return jobSkillsLower.difference(availableSkills).toList();
  }
} 