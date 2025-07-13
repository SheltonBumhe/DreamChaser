import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isFirstLaunch = true;
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isFirstLaunch => _isFirstLaunch;
  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricEnabled => _biometricEnabled;

  AppProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('theme_mode') ?? 0];
    _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> setFirstLaunch(bool value) async {
    _isFirstLaunch = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', value);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
    notifyListeners();
  }
} 