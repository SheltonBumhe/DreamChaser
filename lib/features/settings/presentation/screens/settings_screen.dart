import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Theme'),
                      subtitle: const Text('Choose your preferred theme'),
                      trailing: DropdownButton<ThemeMode>(
                        value: appProvider.themeMode,
                        onChanged: (ThemeMode? newValue) {
                          if (newValue != null) {
                            appProvider.setThemeMode(newValue);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Notification Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notifications'),
                      subtitle: const Text('Manage notification preferences'),
                      trailing: Switch(
                        value: appProvider.notificationsEnabled,
                        onChanged: (value) {
                          appProvider.setNotificationsEnabled(value);
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.fingerprint),
                      title: const Text('Biometric Authentication'),
                      subtitle: const Text('Use fingerprint or face ID'),
                      trailing: Switch(
                        value: appProvider.biometricEnabled,
                        onChanged: (value) {
                          appProvider.setBiometricEnabled(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Language Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: const Text('Choose your preferred language'),
                      trailing: DropdownButton<String>(
                        value: appProvider.selectedLanguage,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            appProvider.setLanguage(newValue);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: 'es',
                            child: Text('Español'),
                          ),
                          DropdownMenuItem(
                            value: 'fr',
                            child: Text('Français'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // About & Support
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('About'),
                      onTap: () {
                        // TODO: Show about dialog
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      onTap: () {
                        // TODO: Navigate to help
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      onTap: () {
                        // TODO: Show privacy policy
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Terms of Service'),
                      onTap: () {
                        // TODO: Show terms of service
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // App Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'DreamChaser',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Version 1.0.0',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'AI-Powered Academic Companion',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 