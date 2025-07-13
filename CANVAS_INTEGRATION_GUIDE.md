# Canvas Integration Guide for DreamChaser

## Overview
This guide explains how DreamChaser integrates with Canvas LMS and addresses concerns about spam reporting and API usage policies.

## Canvas API Integration Safety

### 1. Rate Limiting and Respectful Usage
- **Rate Limits**: The app implements strict rate limiting (max 1 request per 2 seconds)
- **Caching**: All Canvas data is cached for 15 minutes to reduce API calls
- **User Consent**: Canvas integration is opt-in and requires explicit user permission
- **Data Minimization**: Only fetches necessary data (courses, assignments, grades)

### 2. Canvas API Best Practices
```dart
// Example of respectful API usage
class CanvasIntegrationService {
  static const int _rateLimitMs = 2000; // 2 seconds between requests
  static const int _cacheDurationMinutes = 15;
  
  Future<List<Course>> getCourses() async {
    // Check cache first
    if (_isCacheValid()) {
      return _getCachedCourses();
    }
    
    // Respect rate limiting
    await Future.delayed(Duration(milliseconds: _rateLimitMs));
    
    // Make API call with proper headers
    final response = await _httpClient.get(
      '${_canvasBaseUrl}/api/v1/courses',
      headers: {
        'Authorization': 'Bearer $accessToken',
        'User-Agent': 'DreamChaser/1.0 (Educational Tool)',
      },
    );
    
    // Cache the response
    _cacheCourses(response.data);
    return _parseCourses(response.data);
  }
}
```

### 3. User Authentication Flow
1. **OAuth 2.0**: Uses Canvas OAuth for secure authentication
2. **Token Management**: Stores tokens securely with encryption
3. **Scope Limitation**: Only requests necessary permissions:
   - `read_courses` - View enrolled courses
   - `read_grades` - View grades (optional)
   - `read_assignments` - View assignments

### 4. Data Privacy and Security
- **Local Storage**: All Canvas data is stored locally on the device
- **No External Sharing**: Canvas data is never sent to external services
- **Encryption**: Sensitive data is encrypted at rest
- **User Control**: Users can revoke access at any time

## Preventing Spam Reports

### 1. Educational Purpose Declaration
```dart
// App manifest includes educational purpose
const String appDescription = '''
DreamChaser is an educational tool designed to help students:
- Connect academic skills with career opportunities
- Track learning progress and skill development
- Make informed career decisions based on academic performance
''';
```

### 2. Transparent API Usage
- **User Notification**: Users are informed when Canvas data is accessed
- **Purpose Explanation**: Clear explanation of why data is needed
- **Opt-out Option**: Users can disable Canvas integration anytime

### 3. Compliance with Canvas Terms
- **Respectful Usage**: Follows Canvas API terms of service
- **Educational Focus**: Only used for educational purposes
- **No Commercial Use**: No monetization of Canvas data
- **Data Retention**: Minimal data retention (15 minutes cache)

## Implementation Guidelines

### 1. Canvas API Setup
```dart
class CanvasConfig {
  static const String baseUrl = 'https://your-institution.instructure.com';
  static const String clientId = 'your_client_id';
  static const String clientSecret = 'your_client_secret';
  static const List<String> scopes = [
    'read_courses',
    'read_grades',
    'read_assignments',
  ];
}
```

### 2. Error Handling
```dart
Future<List<Course>> getCourses() async {
  try {
    // API call implementation
  } on CanvasApiException catch (e) {
    if (e.statusCode == 429) {
      // Rate limit exceeded - implement exponential backoff
      await _handleRateLimit();
    } else if (e.statusCode == 403) {
      // Permission denied - inform user
      _showPermissionError();
    }
    return [];
  }
}
```

### 3. User Consent Flow
```dart
class CanvasConsentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Canvas Integration'),
          Text('This app will access your Canvas data to:'),
          Text('• Show courses relevant to job opportunities'),
          Text('• Match your skills with job requirements'),
          Text('• Track your academic progress'),
          Text('• Provide career insights based on your coursework'),
          ElevatedButton(
            onPressed: () => _requestCanvasAccess(),
            child: Text('Connect Canvas Account'),
          ),
        ],
      ),
    );
  }
}
```

## Institutional Guidelines

### 1. Before Implementation
- **Contact IT Department**: Inform your institution's IT department
- **Review Policies**: Check institutional Canvas usage policies
- **Get Approval**: Obtain necessary approvals for API integration
- **Document Purpose**: Clearly document the educational purpose

### 2. Communication Strategy
```dart
// In-app communication about Canvas usage
class CanvasInfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Canvas Integration'),
      content: Column(
        children: [
          Text('This app integrates with Canvas to:'),
          Text('• Help you connect coursework with career opportunities'),
          Text('• Provide personalized job recommendations'),
          Text('• Track skill development from your courses'),
          Text('• Offer insights based on your academic performance'),
          SizedBox(height: 16),
          Text('Your data remains private and is not shared with third parties.'),
        ],
      ),
    );
  }
}
```

### 3. Institutional Contact Information
- **IT Support**: [your-institution-it@email.com]
- **Canvas Admin**: [canvas-admin@institution.edu]
- **Privacy Office**: [privacy@institution.edu]

## Troubleshooting

### Common Issues
1. **Rate Limiting**: Implement exponential backoff
2. **Authentication Errors**: Check token validity and scopes
3. **Permission Denied**: Verify user has necessary permissions
4. **Network Issues**: Implement retry logic with delays

### Support Resources
- **Canvas Developer Documentation**: https://canvas.instructure.com/doc/api/
- **Institutional IT Support**: Contact your school's IT department
- **Canvas Community**: https://community.canvaslms.com/

## Best Practices Summary

1. **Respect Rate Limits**: Always implement proper rate limiting
2. **Cache Data**: Reduce API calls through intelligent caching
3. **User Consent**: Always get explicit user permission
4. **Educational Focus**: Maintain clear educational purpose
5. **Transparency**: Be open about data usage and purpose
6. **Security**: Implement proper security measures
7. **Compliance**: Follow institutional and Canvas policies
8. **Documentation**: Keep clear documentation of integration

## Contact Information

For questions about Canvas integration:
- **Developer**: [your-email@domain.com]
- **Institution IT**: [it-support@institution.edu]
- **Canvas Support**: [canvas-support@institution.edu]

---

*This guide ensures responsible and compliant Canvas integration while providing valuable educational features to students.* 