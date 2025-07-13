import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/job_opportunity_model.dart';
import '../models/course_model.dart';
import '../models/skill_model.dart';
import 'api_config.dart';
import 'http_client.dart';

class JobSearchService {
  static final ApiHttpClient _httpClient = ApiHttpClient();

  // Job search parameters
  static Future<List<JobOpportunity>> searchJobs({
    String? query,
    String? location,
    JobType? type,
    double? minSalary,
    double? maxSalary,
    List<String>? requiredSkills,
    int? limit = 50,
  }) async {
    final List<JobOpportunity> allJobs = [];

    try {
      // Try multiple job APIs in parallel
      final futures = <Future<List<JobOpportunity>>>[];

      // Indeed API
      if (ApiConfig.indeedApiKey.isNotEmpty) {
        futures.add(_searchIndeedJobs(
          query: query,
          location: location,
          type: type,
          minSalary: minSalary,
          maxSalary: maxSalary,
          limit: limit,
        ));
      }

      // LinkedIn API
      if (ApiConfig.linkedinApiKey.isNotEmpty) {
        futures.add(_searchLinkedInJobs(
          query: query,
          location: location,
          type: type,
          minSalary: minSalary,
          maxSalary: maxSalary,
          limit: limit,
        ));
      }

      // GitHub Jobs API (free tier)
      futures.add(_searchGitHubJobs(
        query: query,
        location: location,
        type: type,
        limit: limit,
      ));

      // Wait for all API calls to complete
      final results = await Future.wait(futures);
      
      for (final jobs in results) {
        allJobs.addAll(jobs);
      }

      // Apply security filters and deduplication
      final filteredJobs = _applySecurityFilters(allJobs);
      final uniqueJobs = _deduplicateJobs(filteredJobs);

      // Sort by relevance and security level
      uniqueJobs.sort((a, b) {
        // Sort by security level first
        if (a.securityLevel.index != b.securityLevel.index) {
          return b.securityLevel.index.compareTo(a.securityLevel.index);
        }
        // Then by salary (if available)
        final aSalary = _extractSalary(a.salary);
        final bSalary = _extractSalary(b.salary);
        if (aSalary != null && bSalary != null) {
          return bSalary.compareTo(aSalary);
        }
        return 0;
      });

      return uniqueJobs.take(limit ?? 50).toList();
    } catch (e) {
      debugPrint('Job search error: ${e.toString()}');
      return _getMockJobs();
    }
  }

  // Indeed API integration
  static Future<List<JobOpportunity>> _searchIndeedJobs({
    String? query,
    String? location,
    JobType? type,
    double? minSalary,
    double? maxSalary,
    int? limit,
  }) async {
    try {
      final params = <String, String>{};
      if (query != null) params['query'] = query;
      if (location != null) params['location'] = location;
      if (limit != null) params['limit'] = limit.toString();

      final queryString = Uri(queryParameters: params).query;
      final url = '${ApiConfig.indeedBaseUrl}/jobs?$queryString';

      final response = await _httpClient.get(
        url,
        service: 'indeed',
        useCache: true,
        cacheExpiration: ApiConfig.jobCacheExpiration,
      );

      final List<dynamic> jobsData = json.decode(response.body);
      return jobsData.map((data) => JobOpportunity.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Indeed API error: ${e.toString()}');
      return [];
    }
  }

  // LinkedIn API integration
  static Future<List<JobOpportunity>> _searchLinkedInJobs({
    String? query,
    String? location,
    JobType? type,
    double? minSalary,
    double? maxSalary,
    int? limit,
  }) async {
    try {
      final params = <String, String>{};
      if (query != null) params['keywords'] = query;
      if (location != null) params['location'] = location;
      if (limit != null) params['count'] = limit.toString();

      final queryString = Uri(queryParameters: params).query;
      final url = '${ApiConfig.linkedinBaseUrl}/jobSearch?$queryString';

      final response = await _httpClient.get(
        url,
        service: 'linkedin',
        useCache: true,
        cacheExpiration: ApiConfig.jobCacheExpiration,
      );

      final List<dynamic> jobsData = json.decode(response.body);
      return jobsData.map((data) => JobOpportunity.fromJson(data)).toList();
    } catch (e) {
      debugPrint('LinkedIn API error: ${e.toString()}');
      return [];
    }
  }

  // GitHub Jobs API integration (free tier)
  static Future<List<JobOpportunity>> _searchGitHubJobs({
    String? query,
    String? location,
    JobType? type,
    int? limit,
  }) async {
    try {
      final params = <String, String>{};
      if (query != null) params['search'] = query;
      if (location != null) params['location'] = location;
      if (limit != null) params['per_page'] = limit.toString();

      final queryString = Uri(queryParameters: params).query;
      final url = '${ApiConfig.githubJobsBaseUrl}?$queryString';

      final response = await _httpClient.get(
        url,
        service: 'githubjobs',
        useCache: true,
        cacheExpiration: ApiConfig.jobCacheExpiration,
      );

      final List<dynamic> jobsData = json.decode(response.body);
      return jobsData.map((data) => _convertGitHubJobToOpportunity(data)).toList();
    } catch (e) {
      debugPrint('GitHub Jobs API error: ${e.toString()}');
      return [];
    }
  }

  // Convert GitHub Jobs format to JobOpportunity
  static JobOpportunity _convertGitHubJobToOpportunity(Map<String, dynamic> data) {
    return JobOpportunity(
      id: data['id']?.toString() ?? '',
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      salary: data['salary'] ?? 'Not specified',
      type: _parseJobType(data['type']),
      applicationUrl: data['url'],
      applicationEmail: null,
      securityLevel: SecurityLevel.trusted, // GitHub Jobs are generally trusted
      isScam: false,
      isSecure: true,
      skills: _extractSkillsFromDescription(data['description'] ?? ''),
      requirements: _extractRequirementsFromDescription(data['description'] ?? ''),
      benefits: _extractBenefitsFromDescription(data['description'] ?? ''),
      postedDate: data['created_at'] != null 
          ? DateTime.parse(data['created_at']) 
          : DateTime.now(),
      deadline: null,
      remote: data['type']?.toString().toLowerCase().contains('remote') ?? false,
      experienceLevel: _parseExperienceLevel(data['title'] ?? ''),
    );
  }

  // Apply security filters to job listings
  static List<JobOpportunity> _applySecurityFilters(List<JobOpportunity> jobs) {
    return jobs.where((job) {
      // Check for scam indicators
      if (_detectScam(job)) {
        job.isScam = true;
        job.isSecure = false;
        return false; // Remove scam jobs
      }

      // Verify company authenticity
      job.securityLevel = _verifyCompany(job.company);
      
      // Mark as secure if company is verified or trusted
      job.isSecure = job.securityLevel == SecurityLevel.verified || 
                     job.securityLevel == SecurityLevel.trusted;

      return true;
    }).toList();
  }

  // Detect potential scams in job postings
  static bool _detectScam(JobOpportunity job) {
    final text = '${job.title} ${job.description} ${job.company}'.toLowerCase();
    
    // Scam indicators
    final scamIndicators = [
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
      'get rich quick',
      'easy money',
      'work from anywhere',
      'no skills required',
    ];

    for (final indicator in scamIndicators) {
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
    
    // List of trusted companies
    final trustedCompanies = [
      'google', 'microsoft', 'apple', 'amazon', 'meta', 'netflix',
      'tesla', 'spacex', 'uber', 'lyft', 'airbnb', 'stripe', 'square',
      'salesforce', 'oracle', 'ibm', 'intel', 'nvidia', 'amd', 'qualcomm',
      'adobe', 'cisco', 'vmware', 'zoom', 'slack', 'dropbox', 'box',
      'atlassian', 'palantir', 'databricks', 'snowflake', 'mongodb',
    ];
    
    if (trustedCompanies.contains(company)) {
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

  // Deduplicate jobs based on title and company
  static List<JobOpportunity> _deduplicateJobs(List<JobOpportunity> jobs) {
    final Map<String, JobOpportunity> uniqueJobs = {};
    
    for (final job in jobs) {
      final key = '${job.title.toLowerCase()}_${job.company.toLowerCase()}';
      if (!uniqueJobs.containsKey(key)) {
        uniqueJobs[key] = job;
      }
    }
    
    return uniqueJobs.values.toList();
  }

  // Extract salary from string
  static double? _extractSalary(String salary) {
    final match = RegExp(r'\$(\d+(?:,\d{3})*(?:\.\d{2})?)').firstMatch(salary);
    if (match != null) {
      final salaryStr = match.group(1)?.replaceAll(',', '');
      return double.tryParse(salaryStr ?? '');
    }
    return null;
  }

  // Parse job type from string
  static JobType _parseJobType(String? type) {
    if (type == null) return JobType.fullTime;
    
    final typeLower = type.toLowerCase();
    if (typeLower.contains('part')) return JobType.partTime;
    if (typeLower.contains('contract')) return JobType.contract;
    if (typeLower.contains('intern')) return JobType.internship;
    if (typeLower.contains('freelance')) return JobType.freelance;
    
    return JobType.fullTime;
  }

  // Parse experience level from job title
  static ExperienceLevel _parseExperienceLevel(String title) {
    final titleLower = title.toLowerCase();
    
    if (titleLower.contains('senior') || titleLower.contains('lead')) {
      return ExperienceLevel.senior;
    }
    if (titleLower.contains('junior') || titleLower.contains('entry')) {
      return ExperienceLevel.junior;
    }
    if (titleLower.contains('intern') || titleLower.contains('student')) {
      return ExperienceLevel.intern;
    }
    
    return ExperienceLevel.mid;
  }

  // Extract skills from job description
  static List<String> _extractSkillsFromDescription(String description) {
    final skills = <String>{};
    final skillPatterns = [
      'javascript', 'python', 'java', 'c++', 'c#', 'php', 'ruby', 'go',
      'react', 'angular', 'vue', 'node.js', 'express', 'django', 'flask',
      'mysql', 'postgresql', 'mongodb', 'redis', 'aws', 'azure', 'gcp',
      'docker', 'kubernetes', 'git', 'agile', 'scrum', 'machine learning',
      'ai', 'data science', 'sql', 'nosql', 'api', 'rest', 'graphql',
    ];

    final descriptionLower = description.toLowerCase();
    for (final skill in skillPatterns) {
      if (descriptionLower.contains(skill)) {
        skills.add(skill);
      }
    }

    return skills.toList();
  }

  // Extract requirements from job description
  static List<String> _extractRequirementsFromDescription(String description) {
    final requirements = <String>{};
    final requirementPatterns = [
      'bachelor', 'master', 'phd', 'degree', 'certification',
      'experience', 'years', 'knowledge', 'familiarity',
    ];

    final descriptionLower = description.toLowerCase();
    for (final pattern in requirementPatterns) {
      if (descriptionLower.contains(pattern)) {
        requirements.add(pattern);
      }
    }

    return requirements.toList();
  }

  // Extract benefits from job description
  static List<String> _extractBenefitsFromDescription(String description) {
    final benefits = <String>{};
    final benefitPatterns = [
      'health insurance', 'dental', 'vision', '401k', 'retirement',
      'paid time off', 'vacation', 'sick leave', 'remote work',
      'flexible hours', 'gym membership', 'free lunch', 'snacks',
    ];

    final descriptionLower = description.toLowerCase();
    for (final benefit in benefitPatterns) {
      if (descriptionLower.contains(benefit)) {
        benefits.add(benefit);
      }
    }

    return benefits.toList();
  }

  // Mock jobs for development/testing
  static List<JobOpportunity> _getMockJobs() {
    return [
      JobOpportunity(
        id: '1',
        title: 'Senior Software Engineer',
        company: 'Google',
        location: 'Mountain View, CA',
        description: 'Join our team to build scalable applications...',
        salary: '\$150,000 - \$200,000',
        type: JobType.fullTime,
        applicationUrl: 'https://careers.google.com/jobs/123',
        applicationEmail: 'jobs@google.com',
        securityLevel: SecurityLevel.verified,
        isScam: false,
        isSecure: true,
        skills: ['Python', 'JavaScript', 'React', 'AWS'],
        requirements: ['Bachelor degree', '5+ years experience'],
        benefits: ['Health insurance', '401k', 'Remote work'],
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        deadline: DateTime.now().add(const Duration(days: 30)),
        remote: true,
        experienceLevel: ExperienceLevel.senior,
      ),
      JobOpportunity(
        id: '2',
        title: 'Frontend Developer',
        company: 'Microsoft',
        location: 'Seattle, WA',
        description: 'Build modern web applications...',
        salary: '\$120,000 - \$150,000',
        type: JobType.fullTime,
        applicationUrl: 'https://careers.microsoft.com/jobs/456',
        applicationEmail: 'jobs@microsoft.com',
        securityLevel: SecurityLevel.verified,
        isScam: false,
        isSecure: true,
        skills: ['React', 'TypeScript', 'CSS', 'HTML'],
        requirements: ['Bachelor degree', '3+ years experience'],
        benefits: ['Health insurance', 'Dental', 'Vision'],
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        deadline: DateTime.now().add(const Duration(days: 45)),
        remote: false,
        experienceLevel: ExperienceLevel.mid,
      ),
    ];
  }
} 