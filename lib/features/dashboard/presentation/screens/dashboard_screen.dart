import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/canvas_provider.dart';
import '../../../../core/providers/ai_provider.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 24),
              
              // Quick Stats
              _buildQuickStats(),
              
              const SizedBox(height: 24),
              
              // Upcoming Assignments
              _buildUpcomingAssignments(),
              
              const SizedBox(height: 24),
              
              // AI Insights
              _buildAIInsights(),
              
              const SizedBox(height: 24),
              
              // Grade Progress
              _buildGradeProgress(),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox.shrink();

        return Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(user.avatar),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle image error
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                context.go('/profile');
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer<CanvasProvider>(
      builder: (context, canvasProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'GPA',
                value: canvasProvider.overallGPA.toStringAsFixed(2),
                subtitle: 'Current',
                icon: Icons.grade,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Courses',
                value: canvasProvider.courses.length.toString(),
                subtitle: 'Active',
                icon: Icons.school,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Due Soon',
                value: canvasProvider.upcomingAssignments.length.toString(),
                subtitle: 'Assignments',
                icon: Icons.assignment,
                color: AppTheme.warningColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAssignments() {
    return Consumer<CanvasProvider>(
      builder: (context, canvasProvider, child) {
        final upcomingAssignments = canvasProvider.upcomingAssignments.take(3).toList();
        
        if (upcomingAssignments.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Assignments',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/assignments');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...upcomingAssignments.map((assignment) => _buildAssignmentCard(assignment)),
          ],
        );
      },
    );
  }

  Widget _buildAssignmentCard(assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: assignment.priorityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.assignment,
            color: assignment.priorityColor,
            size: 20,
          ),
        ),
        title: Text(
          assignment.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${assignment.timeUntilDueString} • ${assignment.priorityString} Priority',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          onPressed: () {
            // TODO: Mark as complete
          },
          icon: const Icon(Icons.check_circle_outline),
        ),
      ),
    );
  }

  Widget _buildAIInsights() {
    return Consumer<AIProvider>(
      builder: (context, aiProvider, child) {
        final insights = aiProvider.insights.take(2).toList();
        
        if (insights.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI Insights',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/ai-insights');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...insights.map((insight) => _buildInsightCard(insight)),
          ],
        );
      },
    );
  }

  Widget _buildInsightCard(insight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: insight.typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            insight.typeIcon,
            color: insight.typeColor,
            size: 20,
          ),
        ),
        title: Text(
          insight.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          insight.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          insight.timeAgo,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildGradeProgress() {
    return Consumer<CanvasProvider>(
      builder: (context, canvasProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grade Progress',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Overall GPA',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          canvasProvider.overallGPA.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                const FlSpot(0, 3.2),
                                const FlSpot(1, 3.4),
                                const FlSpot(2, 3.6),
                                const FlSpot(3, 3.8),
                                const FlSpot(4, 3.9),
                              ],
                              isCurved: true,
                              color: AppTheme.primaryColor,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppTheme.primaryColor.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Add Assignment',
                icon: Icons.assignment_turned_in,
                color: AppTheme.primaryColor,
                onTap: () {
                  // TODO: Navigate to add assignment
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'View Grades',
                icon: Icons.grade,
                color: AppTheme.secondaryColor,
                onTap: () {
                  context.go('/grades');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'AI Insights',
                icon: Icons.psychology,
                color: AppTheme.accentColor,
                onTap: () {
                  context.go('/ai-insights');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Career',
                icon: Icons.work,
                color: AppTheme.infoColor,
                onTap: () {
                  context.go('/jobs');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 