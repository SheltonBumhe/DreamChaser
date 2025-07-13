import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/job_opportunity_model.dart';
import '../models/course_model.dart';
import '../models/skill_model.dart';

class SecureJobService {
  static const String _baseUrl = 'https://api.securejobs.com/v1';
  static const String _canvasApiUrl = 'https://canvas.instructure.com/api/v1';
  
  // API Keys (in production, these would be stored securely)
  static const String _apiKey = 'your_secure_api_key';
  static const String _canvasToken = 'your_canvas_token';

  // Scam detection patterns
  static const List<String> _scamIndicators = [
    'work from home',
    'make money fast',
    'no experience needed',
    'earn \$1000 daily',
    'send money first',
    'western union',
    'bitcoin payment',
    'urgent hiring',
    'immediate start',
    'no interview required',
  ];

  static const List<String> _trustedCompanies = [
    'google',
    'microsoft',
    'apple',
    'amazon',
    'meta',
    'netflix',
    'tesla',
    'spacex',
    'uber',
    'lyft',
    'airbnb',
    'stripe',
    'square',
    'salesforce',
    'oracle',
    'ibm',
    'intel',
    'nvidia',
    'amd',
    'qualcomm',
  ];

  // Fetch secure job opportunities with scam detection
  static Future<List<JobOpportunity>> fetchSecureJobs({
    String? query,
    JobType? type,
    String? location,
    double? minSalary,
    double? maxSalary,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/jobs'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jobsData = json.decode(response.body);
        final List<JobOpportunity> jobs = [];

        for (final jobData in jobsData) {
          final job = JobOpportunity.fromJson(jobData);
          
          // Apply security filters
          if (!job.isScam && job.isSecure) {
            jobs.add(job);
          }
        }

        // Apply additional filters
        return _applyFilters(jobs, query, type, location, minSalary, maxSalary);
      } else {
        throw Exception('Failed to fetch jobs: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockSecureJobs();
    }
  }

  // Detect potential scams in job postings
  static bool _detectScam(JobOpportunity job) {
    final text = '${job.title} ${job.description} ${job.company}'.toLowerCase();
    
    // Check for scam indicators
    for (final indicator in _scamIndicators) {
      if (text.contains(indicator)) {
        return true;
      }
    }

    // Check for suspicious patterns
    if (_hasSuspiciousPatterns(job)) {
      return true;
    }

    return false;
  }

  static bool _hasSuspiciousPatterns(JobOpportunity job) {
    // Check for unrealistic salaries
    if (job.salary.contains('\$') && job.salary.contains('daily')) {
      final salaryMatch = RegExp(r'\$(\d+)').firstMatch(job.salary);
      if (salaryMatch != null) {
        final dailySalary = int.tryParse(salaryMatch.group(1) ?? '0');
        if (dailySalary != null && dailySalary > 500) {
          return true; // Suspiciously high daily salary
        }
      }
    }

    // Check for unprofessional email domains
    if (job.applicationEmail != null) {
      final email = job.applicationEmail!.toLowerCase();
      if (email.contains('gmail.com') || 
          email.contains('yahoo.com') || 
          email.contains('hotmail.com')) {
        return true; // Personal email for business application
      }
    }

    return false;
  }

  // Verify company authenticity
  static SecurityLevel _verifyCompany(String companyName) {
    final company = companyName.toLowerCase();
    
    if (_trustedCompanies.contains(company)) {
      return SecurityLevel.verified;
    }
    
    // Check for company verification patterns
    if (company.contains('inc') || 
        company.contains('corp') || 
        company.contains('llc') ||
        company.contains('ltd')) {
      return SecurityLevel.trusted;
    }
    
    return SecurityLevel.unverified;
  }

  // Apply filters to job list
  static List<JobOpportunity> _applyFilters(
    List<JobOpportunity> jobs,
    String? query,
    JobType? type,
    String? location,
    double? minSalary,
    double? maxSalary,
  ) {
    return jobs.where((job) {
      // Query filter
      if (query != null && query.isNotEmpty) {
        final searchText = '${job.title} ${job.company} ${job.skills.join(' ')}'.toLowerCase();
        if (!searchText.contains(query.toLowerCase())) {
          return false;
        }
      }

      // Type filter
      if (type != null && job.type != type) {
        return false;
      }

      // Location filter
      if (location != null && location.isNotEmpty) {
        if (!job.location.toLowerCase().contains(location.toLowerCase())) {
          return false;
        }
      }

      // Salary filter
      if (minSalary != null || maxSalary != null) {
        final salaryMatch = RegExp(r'\$(\d+)').firstMatch(job.salary);
        if (salaryMatch != null) {
          final salary = int.tryParse(salaryMatch.group(1) ?? '0') ?? 0;
          if (minSalary != null && salary < minSalary) return false;
          if (maxSalary != null && salary > maxSalary) return false;
        }
      }

      return true;
    }).toList();
  }

  // Get Canvas courses and skills for job matching
  static Future<List<Course>> fetchCanvasCourses() async {
    try {
      final response = await http.get(
        Uri.parse('$_canvasApiUrl/courses'),
        headers: {
          'Authorization': 'Bearer $_canvasToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> coursesData = json.decode(response.body);
        return coursesData.map((data) => Course.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch Canvas courses: ${response.statusCode}');
      }
    } catch (e) {
      // Return mock data if API fails
      return _getMockCanvasCourses();
    }
  }

  // Match job requirements with Canvas skills
  static double _calculateCanvasSkillMatch(
    JobOpportunity job,
    List<Course> courses,
    List<Skill> userSkills,
  ) {
    if (courses.isEmpty) return 0.0;

    final jobSkills = job.skills.map((s) => s.toLowerCase()).toSet();
    final courseSkills = <String>{};
    final userSkillNames = userSkills.map((s) => s.name.toLowerCase()).toSet();

    // Extract skills from course names and descriptions
    for (final course in courses) {
      final courseText = '${course.name} ${course.code}'.toLowerCase();
      for (final skill in jobSkills) {
        if (courseText.contains(skill)) {
          courseSkills.add(skill);
        }
      }
    }

    // Calculate match score
    if (jobSkills.isEmpty) return 0.0;
    
    final matchedSkills = courseSkills.union(userSkillNames);
    return matchedSkills.length / jobSkills.length;
  }

  // Apply for job securely
  static Future<bool> applyForJob(JobOpportunity job, Map<String, dynamic> applicationData) async {
    try {
      if (!job.hasValidApplicationMethod) {
        throw Exception('No valid application method available');
      }

      if (job.isScam) {
        throw Exception('Cannot apply to flagged job posting');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/applications'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'jobId': job.id,
          'applicationData': applicationData,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to apply for job: ${e.toString()}');
    }
  }

  // Mock data for development/testing
  static List<JobOpportunity> _getMockSecureJobs() {
    return [
      JobOpportunity(
        id: '1',
        title: 'Senior Software Engineer',
        company: 'Google',
        location: 'Mountain View, CA',
        type: JobType.fullTime,
        salary: '\$150,000 - \$200,000',
        description: 'Join our team to build scalable software solutions for millions of users.',
        requirements: [
          'Bachelor\'s degree in Computer Science',
          '5+ years of experience',
          'Proficiency in Python, Java, or C++',
          'Experience with cloud platforms',
        ],
        skills: ['Python', 'Java', 'Cloud Computing', 'System Design'],
        postedDate: DateTime.now().subtract(const Duration(days: 5)),
        applicationDeadline: DateTime.now().add(const Duration(days: 30)),
        matchScore: 0.92,
        securityLevel: SecurityLevel.verified,
        isVerifiedCompany: true,
        hasDirectApplication: true,
        applicationUrl: 'https://careers.google.com/jobs/results/123456',
        applicationMethod: ApplicationMethod.direct,
        relatedCanvasCourses: ['CS 301', 'CS 302'],
        requiredCanvasSkills: ['Python', 'System Design'],
        canvasSkillMatch: 0.85,
      ),
      JobOpportunity(
        id: '2',
        title: 'Machine Learning Engineer',
        company: 'Microsoft',
        location: 'Seattle, WA',
        type: JobType.fullTime,
        salary: '\$130,000 - \$180,000',
        description: 'Develop cutting-edge machine learning models and AI solutions.',
        requirements: [
          'Master\'s degree in Computer Science or related field',
          'Experience with ML frameworks (TensorFlow, PyTorch)',
          'Strong statistical background',
          'Python and SQL proficiency',
        ],
        skills: ['Machine Learning', 'Python', 'TensorFlow', 'SQL'],
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
        applicationDeadline: DateTime.now().add(const Duration(days: 25)),
        matchScore: 0.88,
        securityLevel: SecurityLevel.verified,
        isVerifiedCompany: true,
        hasDirectApplication: true,
        applicationUrl: 'https://careers.microsoft.com/us/en/job/789012',
        applicationMethod: ApplicationMethod.direct,
        relatedCanvasCourses: ['CS 401'],
        requiredCanvasSkills: ['Machine Learning', 'Python'],
        canvasSkillMatch: 0.90,
      ),
      JobOpportunity(
        id: '3',
        title: 'Frontend Developer',
        company: 'Netflix',
        location: 'Los Gatos, CA',
        type: JobType.fullTime,
        salary: '\$120,000 - \$160,000',
        description: 'Build user interfaces for millions of users worldwide.',
        requirements: [
          'Bachelor\'s degree in Computer Science',
          'Experience with React, Angular, or Vue',
          'Understanding of web performance',
          'CSS and JavaScript expertise',
        ],
        skills: ['React', 'JavaScript', 'CSS', 'Web Performance'],
        postedDate: DateTime.now().subtract(const Duration(days: 7)),
        applicationDeadline: DateTime.now().add(const Duration(days: 35)),
        matchScore: 0.85,
        securityLevel: SecurityLevel.verified,
        isVerifiedCompany: true,
        hasDirectApplication: true,
        applicationUrl: 'https://jobs.netflix.com/jobs/345678',
        applicationMethod: ApplicationMethod.direct,
        relatedCanvasCourses: ['CS 303'],
        requiredCanvasSkills: ['JavaScript', 'React'],
        canvasSkillMatch: 0.75,
      ),
    ];
  }

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
} 