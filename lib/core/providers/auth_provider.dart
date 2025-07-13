import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userData = prefs.getString('user_data');
    
    if (token != null && userData != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userData));
        _isAuthenticated = true;
        notifyListeners();
      } catch (e) {
        await _logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock user data - in real app, this would come from API
      _currentUser = User(
        id: '1',
        email: email,
        name: 'John Doe',
        avatar: 'https://via.placeholder.com/150',
        institution: 'University of Technology',
        major: 'Computer Science',
        year: 3,
        gpa: 3.8,
        creditsCompleted: 75,
        totalCredits: 120,
      );

      _isAuthenticated = true;
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String institution, String major) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock user data
      _currentUser = User(
        id: '1',
        email: email,
        name: name,
        avatar: 'https://via.placeholder.com/150',
        institution: institution,
        major: major,
        year: 1,
        gpa: 0.0,
        creditsCompleted: 0,
        totalCredits: 120,
      );

      _isAuthenticated = true;
      
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _logout();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<void> updateProfile(User updatedUser) async {
    _currentUser = updatedUser;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));
    
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 