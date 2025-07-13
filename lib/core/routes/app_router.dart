import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/academic/presentation/screens/courses_screen.dart';
import '../../features/academic/presentation/screens/assignments_screen.dart';
import '../../features/academic/presentation/screens/grades_screen.dart';
import '../../features/ai/presentation/screens/ai_insights_screen.dart';
import '../../features/ai/presentation/screens/ai_recommendations_screen.dart';
import '../../features/career/presentation/screens/jobs_screen.dart';
import '../../features/career/presentation/screens/internships_screen.dart';
import '../../features/career/presentation/screens/skills_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      final isAuthenticated = authProvider.isAuthenticated;
      final isFirstLaunch = appProvider.isFirstLaunch;
      
      // If first launch, show onboarding
      if (isFirstLaunch) {
        return '/onboarding';
      }
      
      // If not authenticated, show login
      if (!isAuthenticated) {
        return '/login';
      }
      
      // If authenticated and not first launch, show dashboard
      return null;
    },
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main App
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          
          // Academic
          GoRoute(
            path: '/courses',
            builder: (context, state) => const CoursesScreen(),
          ),
          GoRoute(
            path: '/assignments',
            builder: (context, state) => const AssignmentsScreen(),
          ),
          GoRoute(
            path: '/grades',
            builder: (context, state) => const GradesScreen(),
          ),
          
          // AI Features
          GoRoute(
            path: '/ai-insights',
            builder: (context, state) => const AIInsightsScreen(),
          ),
          GoRoute(
            path: '/ai-recommendations',
            builder: (context, state) => const AIRecommendationsScreen(),
          ),
          
          // Career
          GoRoute(
            path: '/jobs',
            builder: (context, state) => const JobsScreen(),
          ),
          GoRoute(
            path: '/internships',
            builder: (context, state) => const InternshipsScreen(),
          ),
          GoRoute(
            path: '/skills',
            builder: (context, state) => const SkillsScreen(),
          ),
          
          // Profile & Settings
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

class MainLayout extends StatefulWidget {
  final Widget child;
  
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      route: '/',
    ),
    NavigationItem(
      icon: Icons.school,
      label: 'Academic',
      route: '/courses',
    ),
    NavigationItem(
      icon: Icons.psychology,
      label: 'AI Insights',
      route: '/ai-insights',
    ),
    NavigationItem(
      icon: Icons.work,
      label: 'Career',
      route: '/jobs',
    ),
    NavigationItem(
      icon: Icons.person,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          context.go(_navigationItems[index].route);
        },
        type: BottomNavigationBarType.fixed,
        items: _navigationItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
} 