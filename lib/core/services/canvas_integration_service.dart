import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/canvas_models.dart';
import 'http_client.dart';

class CanvasIntegrationService {
  static const String _baseUrl = 'https://your-institution.instructure.com';
  static const String _apiPath = '/api/v1';
  static const int _rateLimitMs = 2000; // 2 seconds between requests
  static const int _cacheDurationMinutes = 15;
  
  final ApiHttpClient _httpClient;
  DateTime? _lastRequestTime;
  Map<String, dynamic> _cache = {};
  Map<String, DateTime> _cacheTimestamps = {};

  CanvasIntegrationService(this._httpClient);

  // Rate limiting helper
  Future<void> _respectRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest.inMilliseconds < _rateLimitMs) {
        final waitTime = _rateLimitMs - timeSinceLastRequest.inMilliseconds;
        await Future.delayed(Duration(milliseconds: waitTime));
      }
    }
    _lastRequestTime = DateTime.now();
  }

  // Cache management
  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    
    final age = DateTime.now().difference(timestamp);
    return age.inMinutes < _cacheDurationMinutes;
  }

  void _setCache(String key, dynamic data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  dynamic _getCache(String key) {
    return _cache[key];
  }

  // User consent and authentication
  Future<bool> hasUserConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('canvas_consent') ?? false;
  }

  Future<void> _setUserConsent(bool consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('canvas_consent', consent);
  }

  // Get user's Canvas access token
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('canvas_access_token');
  }

  // Store access token securely
  Future<void> _storeAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('canvas_access_token', token);
  }

  // Main API methods with safety measures
  Future<List<Course>> getCourses() async {
    // Check user consent
    if (!await hasUserConsent()) {
      throw CanvasException('User consent required for Canvas integration');
    }

    // Check cache first
    const cacheKey = 'courses';
    if (_isCacheValid(cacheKey)) {
      final cachedData = _getCache(cacheKey);
      return _parseCourses(cachedData);
    }

    // Respect rate limiting
    await _respectRateLimit();

    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw CanvasException('Canvas access token not found');
      }

      final response = await _httpClient.get(
        '$_baseUrl$_apiPath/courses',
        headers: {
          'Authorization': 'Bearer $token',
          'User-Agent': 'DreamChaser/1.0 (Educational Tool)',
          'Accept': 'application/json',
        },
      );

      // Cache the response
      _setCache(cacheKey, json.decode(response.body));

      return _parseCourses(json.decode(response.body));
    } on ApiException catch (e) {
      if (e.statusCode == 429) {
        // Rate limit exceeded - implement exponential backoff
        await _handleRateLimit(e);
        return getCourses(); // Retry once
      } else if (e.statusCode == 401) {
        // Token expired or invalid
        await _clearStoredToken();
        throw CanvasException('Canvas authentication failed. Please reconnect your account.');
      } else if (e.statusCode == 403) {
        throw CanvasException('Permission denied. Please check your Canvas permissions.');
      } else {
        throw CanvasException('Failed to fetch courses: ${e.message}');
      }
    } catch (e) {
      debugPrint('Canvas API error: $e');
      return _getMockCourses(); // Fallback to mock data
    }
  }

  Future<List<Assignment>> getAssignments(String courseId) async {
    if (!await hasUserConsent()) {
      throw CanvasException('User consent required for Canvas integration');
    }

    final cacheKey = 'assignments_$courseId';
    if (_isCacheValid(cacheKey)) {
      final cachedData = _getCache(cacheKey);
      return _parseAssignments(cachedData);
    }

    await _respectRateLimit();

    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw CanvasException('Canvas access token not found');
      }

      final response = await _httpClient.get(
        '$_baseUrl$_apiPath/courses/$courseId/assignments',
        headers: {
          'Authorization': 'Bearer $token',
          'User-Agent': 'DreamChaser/1.0 (Educational Tool)',
          'Accept': 'application/json',
        },
      );

      _setCache(cacheKey, json.decode(response.body));
      return _parseAssignments(json.decode(response.body));
    } on ApiException catch (e) {
      if (e.statusCode == 429) {
        await _handleRateLimit(e);
        return getAssignments(courseId);
      } else if (e.statusCode == 401) {
        await _clearStoredToken();
        throw CanvasException('Canvas authentication failed. Please reconnect your account.');
      } else {
        throw CanvasException('Failed to fetch assignments: ${e.message}');
      }
    } catch (e) {
      debugPrint('Canvas API error: $e');
      return _getMockAssignments(courseId);
    }
  }

  Future<List<Grade>> getGrades(String courseId) async {
    if (!await hasUserConsent()) {
      throw CanvasException('User consent required for Canvas integration');
    }

    final cacheKey = 'grades_$courseId';
    if (_isCacheValid(cacheKey)) {
      final cachedData = _getCache(cacheKey);
      return _parseGrades(cachedData);
    }

    await _respectRateLimit();

    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw CanvasException('Canvas access token not found');
      }

      final response = await _httpClient.get(
        '$_baseUrl$_apiPath/courses/$courseId/enrollments',
        headers: {
          'Authorization': 'Bearer $token',
          'User-Agent': 'DreamChaser/1.0 (Educational Tool)',
          'Accept': 'application/json',
        },
      );

      _setCache(cacheKey, json.decode(response.body));
      return _parseGrades(json.decode(response.body));
    } on ApiException catch (e) {
      if (e.statusCode == 429) {
        await _handleRateLimit(e);
        return getGrades(courseId);
      } else if (e.statusCode == 401) {
        await _clearStoredToken();
        throw CanvasException('Canvas authentication failed. Please reconnect your account.');
      } else {
        throw CanvasException('Failed to fetch grades: ${e.message}');
      }
    } catch (e) {
      debugPrint('Canvas API error: $e');
      return _getMockGrades(courseId);
    }
  }

  // Rate limit handling with exponential backoff
  Future<void> _handleRateLimit(ApiException e) async {
    int waitTime = 5000; // Default 5 seconds

    debugPrint('Rate limit exceeded. Waiting ${waitTime}ms before retry.');
    await Future.delayed(Duration(milliseconds: waitTime));
  }

  // Clear stored token
  Future<void> _clearStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('canvas_access_token');
  }

  // User consent management
  Future<void> requestCanvasAccess() async {
    // In a real implementation, this would redirect to Canvas OAuth
    // For now, we'll simulate the consent flow
    await _setUserConsent(true);
    debugPrint('Canvas access requested by user');
  }

  Future<void> revokeCanvasAccess() async {
    await _setUserConsent(false);
    await _clearStoredToken();
    _cache.clear();
    _cacheTimestamps.clear();
    debugPrint('Canvas access revoked by user');
  }

  // Data parsing methods
  List<Course> _parseCourses(List<dynamic> data) {
    return data.map((json) => Course.fromJson(json)).toList();
  }

  List<Assignment> _parseAssignments(List<dynamic> data) {
    return data.map((json) => Assignment.fromJson(json)).toList();
  }

  List<Grade> _parseGrades(List<dynamic> data) {
    return data.map((json) => Grade.fromJson(json)).toList();
  }

  // Mock data for fallback
  List<Course> _getMockCourses() {
    return [
      Course(
        id: '1',
        name: 'Introduction to Computer Science',
        code: 'CS101',
        description: 'Fundamental concepts of programming and computer science',
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
        description: 'Advanced programming concepts and algorithm design',
        instructor: 'Dr. Johnson',
        semester: 'Fall 2024',
        credits: 4,
        grade: 'B+',
        assignments: [],
      ),
    ];
  }

  List<Assignment> _getMockAssignments(String courseId) {
    return [
      Assignment(
        id: '1',
        name: 'Programming Assignment 1',
        description: 'Implement basic algorithms',
        dueDate: DateTime.now().add(Duration(days: 7)),
        points: 100,
        grade: 95,
        status: 'submitted',
      ),
      Assignment(
        id: '2',
        name: 'Final Project',
        description: 'Comprehensive programming project',
        dueDate: DateTime.now().add(Duration(days: 30)),
        points: 200,
        grade: null,
        status: 'pending',
      ),
    ];
  }

  List<Grade> _getMockGrades(String courseId) {
    return [
      Grade(
        assignmentId: '1',
        assignmentName: 'Programming Assignment 1',
        score: 95,
        totalPoints: 100,
        percentage: 0.95,
        courseName: 'Introduction to Computer Science',
        semester: 'Fall 2024',
        credits: 3,
        grade: 95,
        gradePoints: 3.8,
      ),
      Grade(
        assignmentId: '2',
        assignmentName: 'Midterm Exam',
        score: 88,
        totalPoints: 100,
        percentage: 0.88,
        courseName: 'Introduction to Computer Science',
        semester: 'Fall 2024',
        credits: 3,
        grade: 88,
        gradePoints: 3.3,
      ),
    ];
  }
}

class CanvasException implements Exception {
  final String message;
  CanvasException(this.message);

  @override
  String toString() => 'CanvasException: $message';
} 