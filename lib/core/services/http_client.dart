import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiHttpClient {
  static final ApiHttpClient _instance = ApiHttpClient._internal();
  factory ApiHttpClient() => _instance;
  ApiHttpClient._internal();

  final http.Client _client = http.Client();
  final Map<String, int> _requestCounts = {};
  final Map<String, DateTime> _lastRequestTimes = {};

  // Cache for API responses
  final Map<String, Map<String, dynamic>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Headers for different API services
  Map<String, String> _getHeaders(String service) {
    final apiKey = ApiConfig.getApiKey(service);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'DreamChaser/1.0',
    };

    if (apiKey.isNotEmpty) {
      switch (service.toLowerCase()) {
        case 'canvas':
          headers['Authorization'] = 'Bearer $apiKey';
          break;
        case 'indeed':
        case 'linkedin':
          headers['Authorization'] = 'Bearer $apiKey';
          break;
        case 'openai':
          headers['Authorization'] = 'Bearer $apiKey';
          break;
        default:
          if (apiKey.isNotEmpty) {
            headers['X-API-Key'] = apiKey;
          }
      }
    }

    return headers;
  }

  // Rate limiting check
  bool _isRateLimited(String service) {
    final now = DateTime.now();
    final lastRequest = _lastRequestTimes[service];
    final requestCount = _requestCounts[service] ?? 0;

    // Reset counter if more than 1 minute has passed
    if (lastRequest == null || now.difference(lastRequest).inMinutes >= 1) {
      _requestCounts[service] = 1;
      _lastRequestTimes[service] = now;
      return false;
    }

    // Check if we've exceeded the rate limit
    if (requestCount >= ApiConfig.maxRequestsPerMinute) {
      return true;
    }

    _requestCounts[service] = requestCount + 1;
    _lastRequestTimes[service] = now;
    return false;
  }

  // Cache management
  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;

    final now = DateTime.now();
    return now.difference(timestamp) < ApiConfig.cacheExpiration;
  }

  void _setCache(String key, Map<String, dynamic> data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  Map<String, dynamic>? _getCache(String key) {
    if (_isCacheValid(key)) {
      return _cache[key];
    }
    return null;
  }

  // Main GET request method with retry logic
  Future<http.Response> get(
    String url, {
    String? service,
    Map<String, String>? headers,
    bool useCache = true,
    Duration? cacheExpiration,
  }) async {
    final serviceName = service ?? 'default';
    final cacheKey = '${serviceName}_${url}';

    // Check cache first
    if (useCache) {
      final cachedData = _getCache(cacheKey);
      if (cachedData != null) {
        return http.Response(json.encode(cachedData), 200);
      }
    }

    // Check rate limiting
    if (_isRateLimited(serviceName)) {
      throw ApiException(
        'Rate limit exceeded for $serviceName. Please try again later.',
        statusCode: 429,
      );
    }

    // Prepare headers
    final requestHeaders = _getHeaders(serviceName);
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    // Retry logic
    for (int attempt = 1; attempt <= ApiConfig.maxRetries; attempt++) {
      try {
        final response = await _client
            .get(
              Uri.parse(url),
              headers: requestHeaders,
            )
            .timeout(ApiConfig.requestTimeout);

        // Handle successful response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (useCache && response.body.isNotEmpty) {
            try {
              final data = json.decode(response.body);
              _setCache(cacheKey, data);
            } catch (e) {
              // Cache the raw response if JSON parsing fails
              _setCache(cacheKey, {'raw': response.body});
            }
          }
          return response;
        }

        // Handle specific error codes
        switch (response.statusCode) {
          case 401:
            throw ApiException(
              'Authentication failed. Please check your API credentials.',
              statusCode: 401,
            );
          case 403:
            throw ApiException(
              'Access denied. You may not have permission to access this resource.',
              statusCode: 403,
            );
          case 404:
            throw ApiException(
              'Resource not found.',
              statusCode: 404,
            );
          case 429:
            throw ApiException(
              'Rate limit exceeded. Please try again later.',
              statusCode: 429,
            );
          case 500:
          case 502:
          case 503:
            if (attempt < ApiConfig.maxRetries) {
              await Future.delayed(ApiConfig.retryDelay * attempt);
              continue;
            }
            throw ApiException(
              'Server error. Please try again later.',
              statusCode: response.statusCode,
            );
          default:
            throw ApiException(
              'Request failed with status code: ${response.statusCode}',
              statusCode: response.statusCode,
            );
        }
      } catch (e) {
        if (e is ApiException) {
          rethrow;
        }

        if (e is SocketException) {
          if (attempt < ApiConfig.maxRetries) {
            await Future.delayed(ApiConfig.retryDelay * attempt);
            continue;
          }
          throw ApiException(
            'Network error. Please check your internet connection.',
            statusCode: 0,
          );
        }

        if (e is TimeoutException) {
          if (attempt < ApiConfig.maxRetries) {
            await Future.delayed(ApiConfig.retryDelay * attempt);
            continue;
          }
          throw ApiException(
            'Request timeout. Please try again.',
            statusCode: 0,
          );
        }

        throw ApiException(
          'Unexpected error: ${e.toString()}',
          statusCode: 0,
        );
      }
    }

    throw ApiException(
      'Request failed after ${ApiConfig.maxRetries} attempts.',
      statusCode: 0,
    );
  }

  // POST request method
  Future<http.Response> post(
    String url, {
    String? service,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final serviceName = service ?? 'default';

    // Check rate limiting
    if (_isRateLimited(serviceName)) {
      throw ApiException(
        'Rate limit exceeded for $serviceName. Please try again later.',
        statusCode: 429,
      );
    }

    // Prepare headers
    final requestHeaders = _getHeaders(serviceName);
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    // Prepare body
    final requestBody = body != null ? json.encode(body) : null;

    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: requestHeaders,
            body: requestBody,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }

      throw ApiException(
        'POST request failed with status code: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'POST request failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // Clear cache for specific service or all
  void clearCache([String? service]) {
    if (service != null) {
      final keysToRemove = _cache.keys.where((key) => key.startsWith('${service}_')).toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
        _cacheTimestamps.remove(key);
      }
    } else {
      _cache.clear();
      _cacheTimestamps.clear();
    }
  }

  // Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'totalCachedItems': _cache.length,
      'cacheKeys': _cache.keys.toList(),
      'oldestTimestamp': _cacheTimestamps.values.isNotEmpty 
          ? _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b).toIso8601String()
          : null,
      'newestTimestamp': _cacheTimestamps.values.isNotEmpty
          ? _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
          : null,
    };
  }

  // Dispose resources
  void dispose() {
    _client.close();
    _cache.clear();
    _cacheTimestamps.clear();
    _requestCounts.clear();
    _lastRequestTimes.clear();
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? details;

  ApiException(this.message, {required this.statusCode, this.details});

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}

// Timeout exception class
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() {
    return 'TimeoutException: $message (Timeout: ${timeout.inSeconds}s)';
  }
} 