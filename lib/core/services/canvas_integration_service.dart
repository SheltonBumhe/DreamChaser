import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/assignment_model.dart';
import '../models/grade_model.dart';
import '../models/skill_model.dart';
import 'api_config.dart';
import 'http_client.dart';
  
class CanvasIntegrationService {
  static final ApiHttpClient _httpClient = ApiHttpClient();
  
  // Canvas API endpoints
  static const String _coursesEndpoint = '/courses';
  static const String _assignmentsEndpoint = '/courses/{course_id}/assignments';
  static const String _gradesEndpoint = '/courses/{course_id}/enrollments';
  static const String _userEndpoint = '/users/self';
  static const String _accountEndpoint = '/accounts/self';
  static const String _enrollmentsEndpoint = '/users/self/enrollments';

  // Skill mapping from Canvas courses
  static const Map<String, List<String>> courseSkillMapping = {
    'CS 301': ['Algorithms', 'Data Structures', 'Problem Solving'],
    'CS 302': ['Database Design', 'SQL', 'Data Modeling'],
    'CS 303': ['Software Engineering', 'Project Management', 'Team Collaboration'],
    'CS 401': ['Machine Learning', 'Python', 'Statistics', 'Data Analysis'],
    'MATH 201': ['Calculus', 'Mathematics', 'Analytical Thinking'],
    'ENG 101': ['Communication', 'Writing', 'Critical Thinking'],
    'PHYS 101': ['Physics', 'Problem Solving', 'Laboratory Skills'],
  };

  // Fetch user's Canvas courses
  static Future<List<Course>> fetchUserCourses() async {
    try {
      if (!ApiConfig.isCanvasApiAvailable) {
        return _getMockCanvasCourses();
      }

      final url = '${ApiConfig.canvasBaseUrl}$_coursesEndpoint';
      final response = await _httpClient.get(
        url,
        service: 'canvas',
        useCache: true,
        cacheExpiration: ApiConfig.canvasCacheExpiration,
      );

      final List<dynamic> coursesData = json.decode(response.body);
      return coursesData.map((data) => Course.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Canvas API error: ${e.toString()}');
      return _getMockCanvasCourses();
    }
  }

  // Fetch assignments for a specific course
  static Future<List<Assignment>> fetchCourseAssignments(String courseId) async {
    try {
      if (!ApiConfig.isCanvasApiAvailable) {
        return _getMockAssignments(courseId);
      }

      final url = '${ApiConfig.canvasBaseUrl}${_assignmentsEndpoint.replaceAll('{course_id}', courseId)}';
      final response = await _httpClient.get(
        url,
        service: 'canvas',
        useCache: true,
        cacheExpiration: ApiConfig.canvasCacheExpiration,
      );

      final List<dynamic> assignmentsData = json.decode(response.body);
      return assignmentsData.map((data) => Assignment.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Canvas assignments API error: ${e.toString()}');
      return _getMockAssignments(courseId);
    }
  }

  // Fetch grades for a specific course
  static Future<List<Grade>> fetchCourseGrades(String courseId) async {
    try {
      if (!ApiConfig.isCanvasApiAvailable) {
        return _getMockGrades(courseId);
      }

      final url = '${ApiConfig.canvasBaseUrl}${_gradesEndpoint.replaceAll('{course_id}', courseId)}';
      final response = await _httpClient.get(
        url,
        service: 'canvas',
        useCache: true,
        cacheExpiration: ApiConfig.canvasCacheExpiration,
      );

      final List<dynamic> gradesData = json.decode(response.body);
      return gradesData.map((data) => Grade.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Canvas grades API error: ${e.toString()}');
      return _getMockGrades(courseId);
    }
  }

  // Extract skills from Canvas courses
  static List<Skill> extractSkillsFromCourses(List<Course> courses) {
    final List<Skill> skills = [];
    final Set<String> addedSkills = <String>{};

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
  static SkillLevel _getSkillLevel(double grade) {
    if (grade >= 90) return SkillLevel.expert;
    if (grade >= 80) return SkillLevel.advanced;
    if (grade >= 70) return SkillLevel.intermediate;
    return SkillLevel.beginner;
  }

  // Determine skill category
  static SkillCategory _getSkillCategory(String skillName) {
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
  static double calculateSkillMatch(List<String> jobSkills, List<Course> courses) {
    if (jobSkills.isEmpty || courses.isEmpty) return 0.0;

    final Set<String> availableSkills = <String>{};
    
    for (final course in courses) {
      final courseSkills = courseSkillMapping[course.code] ?? [];
      availableSkills.addAll(courseSkills.map((s) => s.toLowerCase()));
    }

    final jobSkillsLower = jobSkills.map((s) => s.toLowerCase()).toSet();
    final matchedSkills = availableSkills.intersection(jobSkillsLower);
    
    return matchedSkills.length / jobSkillsLower.length;
  }

  // Get related courses for a job
  static List<String> getRelatedCourses(List<String> jobSkills) {
    final List<String> relatedCourses = [];
    final jobSkillsLower = jobSkills.map((s) => s.toLowerCase()).toSet();

    for (final entry in courseSkillMapping.entries) {
      final courseSkills = entry.value.map((s) => s.toLowerCase()).toSet();
      if (courseSkills.intersection(jobSkillsLower).isNotEmpty) {
        relatedCourses.add(entry.key);
      }
    }

    return relatedCourses;
  }

  // Fetch user profile information
  static Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      if (!ApiConfig.isCanvasApiAvailable) {
        return _getMockUserProfile();
      }

      final url = '${ApiConfig.canvasBaseUrl}$_userEndpoint';
      final response = await _httpClient.get(
        url,
        service: 'canvas',
        useCache: true,
        cacheExpiration: ApiConfig.canvasCacheExpiration,
      );

      return json.decode(response.body);
    } catch (e) {
      debugPrint('Canvas user profile API error: ${e.toString()}');
      return _getMockUserProfile();
    }
  }

  // Fetch user enrollments
  static Future<List<Map<String, dynamic>>> fetchUserEnrollments() async {
    try {
      if (!ApiConfig.isCanvasApiAvailable) {
        return _getMockEnrollments();
      }

      final url = '${ApiConfig.canvasBaseUrl}$_enrollmentsEndpoint';
      final response = await _httpClient.get(
        url,
        service: 'canvas',
        useCache: true,
        cacheExpiration: ApiConfig.canvasCacheExpiration,
      );

      final List<dynamic> enrollmentsData = json.decode(response.body);
      return enrollmentsData.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Canvas enrollments API error: ${e.toString()}');
      return _getMockEnrollments();
    }
  }

  // Test Canvas API connection
  static Future<bool> testCanvasConnection() async {
    try {
      if (!ApiConfig.isCanvasApiAvailable) {
        return false;
      }

      final url = '${ApiConfig.canvasBaseUrl}$_userEndpoint';
      final response = await _httpClient.get(
        url,
        service: 'canvas',
        useCache: false,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Canvas connection test failed: ${e.toString()}');
      return false;
    }
  }

  // Sync Canvas data with local storage
  static Future<void> syncCanvasData() async {
    try {
      final courses = await fetchUserCourses();
      final List<Assignment> allAssignments = [];
      final List<Grade> allGrades = [];

      for (final course in courses) {
        final assignments = await fetchCourseAssignments(course.id);
        final grades = await fetchCourseGrades(course.id);
        
        allAssignments.addAll(assignments);
        allGrades.addAll(grades);
      }

      // Store data locally (implementation would depend on your storage solution)
      // await _storeCanvasData(courses, allAssignments, allGrades);
    } catch (e) {
      throw Exception('Failed to sync Canvas data: ${e.toString()}');
    }
  }

  // Mock data for development/testing
  static List<Course> _getMockCanvasCourses() {
    return [
      Course(
        id: '1',
        name: 'Advanced Algorithms',
        code: 'CS 301',
        instructor: 'Dr. Sarah Johnson',
        credits: 3,
        grade: 92.5,
        assignments: 8,
        completedAssignments: 6,
      ),
      Course(
        id: '2',
        name: 'Database Systems',
        code: 'CS 302',
        instructor: 'Prof. Michael Chen',
        credits: 4,
        grade: 88.0,
        assignments: 10,
        completedAssignments: 7,
      ),
      Course(
        id: '3',
        name: 'Software Engineering',
        code: 'CS 303',
        instructor: 'Dr. Emily Rodriguez',
        credits: 3,
        grade: 95.2,
        assignments: 12,
        completedAssignments: 9,
      ),
      Course(
        id: '4',
        name: 'Machine Learning',
        code: 'CS 401',
        instructor: 'Prof. David Kim',
        credits: 4,
        grade: 91.8,
        assignments: 15,
        completedAssignments: 11,
      ),
    ];
  }

  static List<Assignment> _getMockAssignments(String courseId) {
    return [
      Assignment(
        id: '1',
        courseId: courseId,
        title: 'Dynamic Programming Project',
        description: 'Implement optimal substructure algorithms',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        points: 100,
        isCompleted: false,
        priority: AssignmentPriority.high,
      ),
      Assignment(
        id: '2',
        courseId: courseId,
        title: 'Database Design Final',
        description: 'Design and implement a complete database system',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        points: 150,
        isCompleted: false,
        priority: AssignmentPriority.high,
      ),
    ];
  }

  static List<Grade> _getMockGrades(String courseId) {
    return [
      Grade(
        courseId: courseId,
        courseName: 'Advanced Algorithms',
        grade: 92.5,
        gradePoints: 4.0,
        credits: 3,
        semester: 'Fall 2024',
      ),
    ];
  }

  // Mock user profile data
  static Map<String, dynamic> _getMockUserProfile() {
    return {
      'id': 12345,
      'name': 'John Doe',
      'short_name': 'John',
      'sortable_name': 'Doe, John',
      'email': 'john.doe@university.edu',
      'login_id': 'johndoe',
      'avatar_url': 'https://example.com/avatar.jpg',
      'locale': 'en',
      'time_zone': 'America/New_York',
      'bio': 'Computer Science Student',
    };
  }

  // Mock enrollments data
  static List<Map<String, dynamic>> _getMockEnrollments() {
    return [
      {
        'id': 1,
        'user_id': 12345,
        'course_id': 1,
        'course_section_id': 1,
        'enrollment_state': 'active',
        'limit_privileges_to_course_section': false,
        'role': 'StudentEnrollment',
        'role_id': 3,
        'type': 'StudentEnrollment',
        'user_id': 12345,
        'course_integration_id': null,
        'sis_course_id': null,
        'sis_section_id': null,
        'sis_user_id': null,
        'html_url': 'https://canvas.instructure.com/courses/1/users/12345',
        'grades': {
          'html_url': 'https://canvas.instructure.com/courses/1/grades/12345',
          'current_score': 92.5,
          'current_grade': 'A',
          'final_score': null,
          'final_grade': null,
          'unposted_current_score': 92.5,
          'unposted_current_grade': 'A',
          'unposted_final_score': null,
          'unposted_final_grade': null,
        },
      },
    ];
  }
} 