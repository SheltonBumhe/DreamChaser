# 🚀 DreamChaser API Integration Setup Guide

This guide will help you set up real API integrations for DreamChaser, replacing mock data with live services.

## 📋 Table of Contents

1. [Canvas API Setup](#canvas-api-setup)
2. [Job Search APIs](#job-search-apis)
3. [AI/ML APIs](#aiml-apis)
4. [Environment Configuration](#environment-configuration)
5. [Testing APIs](#testing-apis)
6. [Production Deployment](#production-deployment)

---

## 🎓 Canvas API Setup

### Step 1: Get Canvas API Token

1. **Log into your Canvas account**
2. **Go to Settings** → **Approved Integrations**
3. **Click "New Access Token"**
4. **Set permissions:**
   - `read:grades`
   - `read:assignments`
   - `read:courses`
   - `read:enrollments`
5. **Copy the generated token**

### Step 2: Configure Canvas API

```bash
# Set environment variable
export CANVAS_API_TOKEN="your_canvas_token_here"
```

### Step 3: Test Canvas Connection

```dart
// Test the connection
final isConnected = await CanvasIntegrationService.testCanvasConnection();
print('Canvas connected: $isConnected');
```

---

## 💼 Job Search APIs

### Option 1: Indeed API (Recommended)

#### Step 1: Sign Up for Indeed API
1. **Visit:** https://developer.indeed.com/
2. **Create account** and apply for API access
3. **Wait for approval** (usually 1-2 business days)
4. **Get your API key**

#### Step 2: Configure Indeed API
```bash
export INDEED_API_KEY="your_indeed_api_key_here"
```

### Option 2: LinkedIn API

#### Step 1: LinkedIn Developer Setup
1. **Visit:** https://developer.linkedin.com/
2. **Create a LinkedIn App**
3. **Request access to Jobs API**
4. **Get your API credentials**

#### Step 2: Configure LinkedIn API
```bash
export LINKEDIN_API_KEY="your_linkedin_api_key_here"
```

### Option 3: GitHub Jobs API (Free)

**No setup required** - this API is free and doesn't require authentication.

---

## 🤖 AI/ML APIs

### OpenAI API Setup

#### Step 1: Get OpenAI API Key
1. **Visit:** https://platform.openai.com/
2. **Sign up** for an account
3. **Go to API Keys** section
4. **Create a new API key**
5. **Copy the key**

#### Step 2: Configure OpenAI API
```bash
export OPENAI_API_KEY="your_openai_api_key_here"
```

---

## ⚙️ Environment Configuration

### Method 1: Environment Variables (Recommended)

Create a `.env` file in your project root:

```env
# Canvas API
CANVAS_API_TOKEN=your_canvas_token_here

# Job Search APIs
INDEED_API_KEY=your_indeed_api_key_here
LINKEDIN_API_KEY=your_linkedin_api_key_here

# AI/ML APIs
OPENAI_API_KEY=your_openai_api_key_here

# Optional: Scam Detection API
SCAM_DETECTION_API_KEY=your_scam_detection_key_here

# Optional: Company Verification API
COMPANY_VERIFICATION_API_KEY=your_company_verification_key_here
```

### Method 2: Flutter Environment Variables

For Flutter web deployment, set environment variables in your build command:

```bash
flutter build web --dart-define=CANVAS_API_TOKEN=your_token \
                  --dart-define=INDEED_API_KEY=your_key \
                  --dart-define=OPENAI_API_KEY=your_key
```

### Method 3: Secure Storage (Mobile Apps)

For mobile apps, use secure storage:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Store API keys securely
await storage.write(key: 'CANVAS_API_TOKEN', value: 'your_token');
await storage.write(key: 'INDEED_API_KEY', value: 'your_key');

// Retrieve API keys
final canvasToken = await storage.read(key: 'CANVAS_API_TOKEN');
final indeedKey = await storage.read(key: 'INDEED_API_KEY');
```

---

## 🧪 Testing APIs

### Test Canvas Integration

```dart
import 'package:dream_chaser/core/services/canvas_integration_service.dart';

void testCanvasAPI() async {
  try {
    // Test connection
    final isConnected = await CanvasIntegrationService.testCanvasConnection();
    print('Canvas connected: $isConnected');
    
    if (isConnected) {
      // Fetch user profile
      final profile = await CanvasIntegrationService.fetchUserProfile();
      print('User profile: $profile');
      
      // Fetch courses
      final courses = await CanvasIntegrationService.fetchUserCourses();
      print('Courses: ${courses.length}');
      
      // Fetch assignments
      if (courses.isNotEmpty) {
        final assignments = await CanvasIntegrationService.fetchCourseAssignments(courses.first.id);
        print('Assignments: ${assignments.length}');
      }
    }
  } catch (e) {
    print('Canvas API test failed: $e');
  }
}
```

### Test Job Search APIs

```dart
import 'package:dream_chaser/core/services/job_search_service.dart';

void testJobSearchAPI() async {
  try {
    final jobs = await JobSearchService.searchJobs(
      query: 'software engineer',
      location: 'San Francisco',
      limit: 10,
    );
    
    print('Found ${jobs.length} jobs');
    
    for (final job in jobs) {
      print('${job.title} at ${job.company}');
      print('Security: ${job.securityLevel}');
      print('Is Secure: ${job.isSecure}');
      print('Is Scam: ${job.isScam}');
      print('---');
    }
  } catch (e) {
    print('Job search test failed: $e');
  }
}
```

### Test AI Services

```dart
import 'package:dream_chaser/core/services/ai_service.dart';

void testAIServices() async {
  try {
    // Test skill matching
    final matchScore = await AIService.calculateSkillMatch(
      ['Python', 'React', 'AWS'],
      mockCourses,
      mockSkills,
    );
    print('Skill match score: $matchScore%');
    
    // Test job recommendations
    final recommendations = await AIService.generateJobRecommendations(
      courses: mockCourses,
      userSkills: mockSkills,
      availableJobs: mockJobs,
      limit: 5,
    );
    print('AI recommendations: ${recommendations.length}');
    
    // Test career insights
    final insights = await AIService.generateCareerInsights(
      courses: mockCourses,
      userSkills: mockSkills,
      recentJobs: mockJobs,
    );
    print('Career insights: ${insights.length}');
    
  } catch (e) {
    print('AI services test failed: $e');
  }
}
```

---

## 🚀 Production Deployment

### GitHub Actions Configuration

Update your `.github/workflows/deploy.yml`:

```yaml
name: Deploy Flutter Web to GitHub Pages

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
          
      - name: Get dependencies
        run: flutter pub get
        
      - name: Build web with API keys
        run: |
          flutter build web --release \
            --dart-define=CANVAS_API_TOKEN=${{ secrets.CANVAS_API_TOKEN }} \
            --dart-define=INDEED_API_KEY=${{ secrets.INDEED_API_KEY }} \
            --dart-define=OPENAI_API_KEY=${{ secrets.OPENAI_API_KEY }} \
            --dart-define=LINKEDIN_API_KEY=${{ secrets.LINKEDIN_API_KEY }}
        
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
          force_orphan: true
```

### GitHub Secrets Setup

1. **Go to your repository** → **Settings** → **Secrets and variables** → **Actions**
2. **Add the following secrets:**
   - `CANVAS_API_TOKEN`
   - `INDEED_API_KEY`
   - `OPENAI_API_KEY`
   - `LINKEDIN_API_KEY`

### Local Development

For local development, create a `local_env.dart` file:

```dart
// lib/core/config/local_env.dart
class LocalEnv {
  static const String canvasToken = String.fromEnvironment(
    'CANVAS_API_TOKEN',
    defaultValue: 'your_local_canvas_token',
  );
  
  static const String indeedApiKey = String.fromEnvironment(
    'INDEED_API_KEY',
    defaultValue: 'your_local_indeed_key',
  );
  
  static const String openaiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'your_local_openai_key',
  );
}
```

---

## 🔧 API Configuration Tips

### Rate Limiting

All APIs have rate limits. The app includes built-in rate limiting:

- **Canvas API:** 600 requests per 10 minutes
- **Indeed API:** 100 requests per day (free tier)
- **LinkedIn API:** 100 requests per day (free tier)
- **OpenAI API:** 3,500 requests per minute

### Error Handling

The app includes comprehensive error handling:

```dart
try {
  final jobs = await JobSearchService.searchJobs(query: 'developer');
} on ApiException catch (e) {
  if (e.statusCode == 429) {
    // Rate limit exceeded
    showRateLimitMessage();
  } else if (e.statusCode == 401) {
    // Authentication failed
    showAuthError();
  } else {
    // Other API errors
    showErrorMessage(e.message);
  }
}
```

### Caching Strategy

The app implements intelligent caching:

- **Canvas data:** 15 minutes cache
- **Job listings:** 30 minutes cache
- **AI responses:** 1 hour cache

### Fallback Strategy

When APIs are unavailable, the app falls back to:

1. **Cached data** (if available)
2. **Mock data** (for development)
3. **Graceful degradation** (show limited features)

---

## 🛡️ Security Best Practices

### API Key Management

1. **Never commit API keys** to version control
2. **Use environment variables** for local development
3. **Use GitHub Secrets** for production deployment
4. **Rotate keys regularly** (every 90 days)

### Data Privacy

1. **Minimize data collection** - only fetch what you need
2. **Cache responsibly** - don't cache sensitive data
3. **Implement user consent** for data usage
4. **Follow GDPR/CCPA** compliance

### Network Security

1. **Use HTTPS** for all API calls
2. **Validate API responses** before processing
3. **Implement request timeouts** (30 seconds)
4. **Add retry logic** for failed requests

---

## 📊 Monitoring & Analytics

### API Health Monitoring

```dart
// Monitor API health
class APIHealthMonitor {
  static Future<Map<String, bool>> checkAllAPIs() async {
    return {
      'canvas': await CanvasIntegrationService.testCanvasConnection(),
      'jobs': await JobSearchService.testJobAPIs(),
      'ai': await AIService.testAIConnection(),
    };
  }
}
```

### Usage Analytics

Track API usage for optimization:

```dart
class APIUsageTracker {
  static void trackAPICall(String service, String endpoint) {
    // Log API usage for monitoring
    print('API Call: $service/$endpoint');
  }
}
```

---

## 🆘 Troubleshooting

### Common Issues

1. **Canvas API 401 Error**
   - Check if token is valid
   - Verify token permissions
   - Regenerate token if needed

2. **Job API Rate Limits**
   - Implement exponential backoff
   - Use multiple API providers
   - Cache results aggressively

3. **AI API Timeouts**
   - Reduce prompt complexity
   - Implement request batching
   - Use fallback responses

### Debug Mode

Enable debug logging:

```dart
// In your main.dart
if (kDebugMode) {
  ApiHttpClient().enableDebugLogging();
}
```

---

## 📞 Support

For API integration issues:

1. **Check API documentation** for each service
2. **Verify API keys** are correct and active
3. **Test with curl/Postman** before Flutter integration
4. **Check rate limits** and usage quotas
5. **Review error logs** for specific issues

---

**🎉 Congratulations!** Your DreamChaser app now has real API integrations. The app will automatically fall back to mock data when APIs are unavailable, ensuring a smooth user experience in all scenarios. 