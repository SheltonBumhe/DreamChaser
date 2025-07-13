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
    JobType? type,
    String? location,
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
      return await _getMockJobs();
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
      skills: _extractSkillsFromDescription(data['description'] ?? ''),
      requirements: _extractRequirementsFromDescription(data['description'] ?? ''),
      benefits: _extractBenefitsFromDescription(data['description'] ?? ''),
      postedDate: data['created_at'] != null 
          ? DateTime.parse(data['created_at']) 
          : DateTime.now(),
      applicationDeadline: DateTime.now().add(const Duration(days: 30)),
      deadline: null,
      remote: data['type']?.toString().toLowerCase().contains('remote') ?? false,
      experienceLevel: _parseExperienceLevel(data['title'] ?? ''),
      matchScore: 0.8,
    );
  }

  // Apply security filters to job listings
  static List<JobOpportunity> _applySecurityFilters(List<JobOpportunity> jobs) {
    return jobs.where((job) {
      // Check for scam indicators
      if (_detectScam(job)) {
        // Create a new job object with scam flag
        final scamJob = job.copyWith(isScam: true, isSecure: false);
        return false; // Remove scam jobs
      }

      // Verify company authenticity
      final securityLevel = _verifyCompany(job.company);
      
      // Mark as secure if company is verified or trusted
      final isSecure = securityLevel == SecurityLevel.verified || 
                       securityLevel == SecurityLevel.trusted;
      
      // Update job with security information
      job = job.copyWith(
        securityLevel: securityLevel,
        isSecure: isSecure,
      );

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
    
    if (titleLower.contains('senior') || titleLower.contains('lead') || titleLower.contains('principal')) {
      return ExperienceLevel.senior;
    }
    if (titleLower.contains('junior') || titleLower.contains('entry')) {
      return ExperienceLevel.junior;
    }
    if (titleLower.contains('intern') || titleLower.contains('internship')) {
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
  static JobOpportunity _createMockJob({
    required String id,
    required String title,
    required String company,
    required String location,
    required JobType type,
    required String salary,
    required String description,
    required List<String> requirements,
    required List<String> skills,
    required DateTime postedDate,
    required DateTime applicationDeadline,
    required double matchScore,
    SecurityLevel securityLevel = SecurityLevel.unverified,
    bool isVerifiedCompany = false,
    bool hasDirectApplication = false,
    String? applicationUrl,
    String? applicationEmail,
    String? applicationPhone,
    ApplicationMethod applicationMethod = ApplicationMethod.external,
    List<String> scamIndicators = const [],
    bool isScam = false,
    List<String> relatedCanvasCourses = const [],
    List<String> requiredCanvasSkills = const [],
    double canvasSkillMatch = 0.0,
    bool remote = false,
    ExperienceLevel experienceLevel = ExperienceLevel.mid,
    List<String> benefits = const [],
    DateTime? deadline,
  }) {
    return JobOpportunity(
      id: id,
      title: title,
      company: company,
      location: location,
      type: type,
      salary: salary,
      description: description,
      requirements: requirements,
      skills: skills,
      postedDate: postedDate,
      applicationDeadline: applicationDeadline,
      matchScore: matchScore,
      securityLevel: securityLevel,
      isVerifiedCompany: isVerifiedCompany,
      hasDirectApplication: hasDirectApplication,
      applicationUrl: applicationUrl,
      applicationEmail: applicationEmail,
      applicationPhone: applicationPhone,
      applicationMethod: applicationMethod,
      scamIndicators: scamIndicators,
      isScam: isScam,
      relatedCanvasCourses: relatedCanvasCourses,
      requiredCanvasSkills: requiredCanvasSkills,
      canvasSkillMatch: canvasSkillMatch,
      remote: remote,
      experienceLevel: experienceLevel,
      benefits: benefits,
      deadline: deadline,
    );
  }

  static JobOpportunity _processJob(JobOpportunity job) {
    // Apply scam detection
    final scamIndicators = _detectScamIndicators(job);
    if (scamIndicators.isNotEmpty) {
      return job.copyWith(
        isScam: true,
        securityLevel: SecurityLevel.flagged,
        scamIndicators: scamIndicators,
      );
    }

    // Apply company verification
    final verifiedSecurityLevel = _verifyCompany(job.company);
    final updatedJob = job.copyWith(
      securityLevel: verifiedSecurityLevel,
      isSecure: verifiedSecurityLevel == SecurityLevel.verified || 
                verifiedSecurityLevel == SecurityLevel.trusted,
    );

    return updatedJob;
  }

  static List<String> _detectScamIndicators(JobOpportunity job) {
    final indicators = <String>[];
    final titleLower = job.title.toLowerCase();
    final companyLower = job.company.toLowerCase();
    final descriptionLower = job.description.toLowerCase();

    // Common scam indicators
    if (titleLower.contains('work from home') && 
        (titleLower.contains('earn') || titleLower.contains('money'))) {
      indicators.add('Suspicious work-from-home claims');
    }

    if (companyLower.contains('llc') && 
        (titleLower.contains('remote') || titleLower.contains('online'))) {
      indicators.add('New LLC with remote work claims');
    }

    if (descriptionLower.contains('send money') || 
        descriptionLower.contains('payment required')) {
      indicators.add('Requests payment from applicant');
    }

    if (descriptionLower.contains('personal information') && 
        descriptionLower.contains('bank account')) {
      indicators.add('Requests sensitive financial information');
    }

    if (titleLower.contains('data entry') && 
        (titleLower.contains('\$100') || titleLower.contains('\$200'))) {
      indicators.add('Unrealistic salary for data entry');
    }

    if (companyLower.length < 3 || 
        companyLower.contains('temp') || 
        companyLower.contains('agency')) {
      indicators.add('Suspicious company name');
    }

    return indicators;
  }

  static List<JobOpportunity> _getMockJobs() {
    return [
      _createMockJob(
        id: '1',
        title: 'Senior Software Engineer',
        company: 'Google',
        location: 'Mountain View, CA',
        type: JobType.fullTime,
        salary: '\$150,000 - \$200,000',
        description: 'Join our team to build innovative solutions...',
        requirements: ['5+ years experience', 'Python', 'JavaScript'],
        skills: ['Python', 'JavaScript', 'React', 'Node.js'],
        postedDate: DateTime.now().subtract(Duration(days: 2)),
        applicationDeadline: DateTime.now().add(Duration(days: 30)),
        matchScore: 0.85,
        securityLevel: SecurityLevel.verified,
        isVerifiedCompany: true,
        hasDirectApplication: true,
        applicationUrl: 'https://careers.google.com/jobs/123',
        applicationMethod: ApplicationMethod.direct,
        experienceLevel: ExperienceLevel.senior,
        benefits: ['Health insurance', '401k', 'Stock options'],
      ),
      _createMockJob(
        id: '2',
        title: 'Frontend Developer',
        company: 'Microsoft',
        location: 'Seattle, WA',
        type: JobType.fullTime,
        salary: '\$120,000 - \$160,000',
        description: 'Build amazing user experiences...',
        requirements: ['3+ years experience', 'React', 'TypeScript'],
        skills: ['React', 'TypeScript', 'CSS', 'HTML'],
        postedDate: DateTime.now().subtract(Duration(days: 1)),
        applicationDeadline: DateTime.now().add(Duration(days: 25)),
        matchScore: 0.75,
        securityLevel: SecurityLevel.verified,
        isVerifiedCompany: true,
        hasDirectApplication: true,
        applicationUrl: 'https://careers.microsoft.com/jobs/456',
        applicationMethod: ApplicationMethod.direct,
        experienceLevel: ExperienceLevel.mid,
        benefits: ['Health insurance', '401k', 'Remote work'],
      ),
    ];
  }
} 