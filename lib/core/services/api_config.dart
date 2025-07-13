import 'package:flutter/foundation.dart';

class ApiConfig {
  // Canvas API Configuration
  static const String canvasBaseUrl = 'https://canvas.instructure.com/api/v1';
  static const String canvasToken = String.fromEnvironment('CANVAS_API_TOKEN', defaultValue: '');
  
  // Job Search APIs
  static const String indeedBaseUrl = 'https://api.indeed.com/v2';
  static const String indeedApiKey = String.fromEnvironment('INDEED_API_KEY', defaultValue: '');
  
  static const String linkedinBaseUrl = 'https://api.linkedin.com/v2';
  static const String linkedinApiKey = String.fromEnvironment('LINKEDIN_API_KEY', defaultValue: '');
  
  // GitHub Jobs API (free tier)
  static const String githubJobsBaseUrl = 'https://jobs.github.com/positions.json';
  
  // Scam Detection API
  static const String scamDetectionBaseUrl = 'https://api.scamdetector.com/v1';
  static const String scamDetectionApiKey = String.fromEnvironment('SCAM_DETECTION_API_KEY', defaultValue: '');
  
  // Company Verification API
  static const String companyVerificationBaseUrl = 'https://api.companyverifier.com/v1';
  static const String companyVerificationApiKey = String.fromEnvironment('COMPANY_VERIFICATION_API_KEY', defaultValue: '');
  
  // AI/ML APIs for skill matching
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
  static const String openaiApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  
  // Local development fallback
  static const bool useMockData = kDebugMode;
  
  // API Rate limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxRequestsPerHour = 1000;
  
  // Timeout settings
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  
  // Retry settings
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Cache settings
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration canvasCacheExpiration = Duration(minutes: 15);
  static const Duration jobCacheExpiration = Duration(minutes: 30);
  
  // Security settings
  static const List<String> allowedDomains = [
    'canvas.instructure.com',
    'api.indeed.com',
    'api.linkedin.com',
    'jobs.github.com',
    'api.openai.com',
  ];
  
  // Feature flags
  static const bool enableRealCanvasIntegration = true;
  static const bool enableRealJobSearch = true;
  static const bool enableScamDetection = true;
  static const bool enableCompanyVerification = true;
  static const bool enableAISkillMatching = true;
  
  // Environment detection
  static bool get isProduction => !kDebugMode;
  static bool get isDevelopment => kDebugMode;
  static bool get isTest => kDebugMode && const bool.fromEnvironment('TESTING');
  
  // API Status
  static bool get isCanvasApiAvailable => canvasToken.isNotEmpty;
  static bool get isJobSearchAvailable => indeedApiKey.isNotEmpty || linkedinApiKey.isNotEmpty;
  static bool get isScamDetectionAvailable => scamDetectionApiKey.isNotEmpty;
  static bool get isCompanyVerificationAvailable => companyVerificationApiKey.isNotEmpty;
  static bool get isAIAvailable => openaiApiKey.isNotEmpty;
  
  // Get appropriate API key based on service
  static String getApiKey(String service) {
    switch (service.toLowerCase()) {
      case 'canvas':
        return canvasToken;
      case 'indeed':
        return indeedApiKey;
      case 'linkedin':
        return linkedinApiKey;
      case 'scamdetection':
        return scamDetectionApiKey;
      case 'companyverification':
        return companyVerificationApiKey;
      case 'openai':
        return openaiApiKey;
      default:
        return '';
    }
  }
  
  // Get base URL for service
  static String getBaseUrl(String service) {
    switch (service.toLowerCase()) {
      case 'canvas':
        return canvasBaseUrl;
      case 'indeed':
        return indeedBaseUrl;
      case 'linkedin':
        return linkedinBaseUrl;
      case 'githubjobs':
        return githubJobsBaseUrl;
      case 'scamdetection':
        return scamDetectionBaseUrl;
      case 'companyverification':
        return companyVerificationBaseUrl;
      case 'openai':
        return openaiBaseUrl;
      default:
        return '';
    }
  }
} 