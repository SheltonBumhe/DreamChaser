import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers/career_provider.dart';
import '../../../../core/models/job_opportunity_model.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String _searchQuery = '';
  JobType? _selectedType;
  SecurityLevel? _selectedSecurityLevel;
  bool _showOnlySecure = true;
  bool _showOnlyCanvasJobs = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Job Opportunities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CareerProvider>().refreshData(),
          ),
        ],
      ),
      body: Consumer<CareerProvider>(
        builder: (context, careerProvider, child) {
          if (careerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (careerProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    careerProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => careerProvider.refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredJobs = _getFilteredJobs(careerProvider);

          if (filteredJobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No jobs found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return _buildJobCard(context, job, careerProvider);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search jobs, companies, or skills...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Secure Only'),
            selected: _showOnlySecure,
            onSelected: (selected) {
              setState(() {
                _showOnlySecure = selected;
              });
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Canvas Jobs'),
            selected: _showOnlyCanvasJobs,
            onSelected: (selected) {
              setState(() {
                _showOnlyCanvasJobs = selected;
              });
            },
          ),
          const SizedBox(width: 8),
          if (_selectedType != null)
            FilterChip(
              label: Text(_selectedType!.toString().split('.').last),
              onSelected: (selected) {
                setState(() {
                  _selectedType = null;
                });
              },
            ),
          const SizedBox(width: 8),
          if (_selectedSecurityLevel != null)
            FilterChip(
              label: Text(_selectedSecurityLevel!.toString().split('.').last),
              onSelected: (selected) {
                setState(() {
                  _selectedSecurityLevel = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, JobOpportunity job, CareerProvider careerProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              job.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: job.securityLevelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: job.securityLevelColor),
                            ),
                            child: Text(
                              job.securityLevelString,
                              style: TextStyle(
                                color: job.securityLevelColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        job.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: job.overallMatchScoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(job.overallMatchScore * 100).toInt()}%',
                        style: TextStyle(
                          color: job.overallMatchScoreColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.typeString,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              job.salary,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: job.skills.take(3).map((skill) => Chip(
                label: Text(skill),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              )).toList(),
            ),
            if (job.hasCanvasIntegration) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'Canvas Integration',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  job.postedTimeAgo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (job.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Urgent',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showJobDetails(context, job),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: job.hasValidApplicationMethod
                        ? () => _applyForJob(context, job, careerProvider)
                        : null,
                    icon: const Icon(Icons.send),
                    label: Text(job.applicationMethodString),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: job.hasValidApplicationMethod
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<JobOpportunity> _getFilteredJobs(CareerProvider careerProvider) {
    List<JobOpportunity> jobs = careerProvider.jobOpportunities;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      jobs = jobs.where((job) {
        final searchText = '${job.title} ${job.company} ${job.skills.join(' ')}'.toLowerCase();
        return searchText.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply security filter
    if (_showOnlySecure) {
      jobs = jobs.where((job) => job.isSecure).toList();
    }

    // Apply Canvas filter
    if (_showOnlyCanvasJobs) {
      jobs = jobs.where((job) => job.hasCanvasIntegration).toList();
    }

    // Apply type filter
    if (_selectedType != null) {
      jobs = jobs.where((job) => job.type == _selectedType).toList();
    }

    // Apply security level filter
    if (_selectedSecurityLevel != null) {
      jobs = jobs.where((job) => job.securityLevel == _selectedSecurityLevel).toList();
    }

    return jobs;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Jobs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<JobType>(
              decoration: const InputDecoration(labelText: 'Job Type'),
              value: _selectedType,
              items: JobType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.toString().split('.').last),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SecurityLevel>(
              decoration: const InputDecoration(labelText: 'Security Level'),
              value: _selectedSecurityLevel,
              items: SecurityLevel.values.map((level) => DropdownMenuItem(
                value: level,
                child: Text(level.toString().split('.').last),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSecurityLevel = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedSecurityLevel = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showJobDetails(BuildContext context, JobOpportunity job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Company: ${job.company}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Location: ${job.location}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Salary: ${job.salary}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(job.description),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Requirements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...job.requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(req)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              Text(
                'Skills',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: job.skills.map((skill) => Chip(label: Text(skill))).toList(),
              ),
              if (job.hasCanvasIntegration) ...[
                const SizedBox(height: 16),
                Text(
                  'Canvas Integration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Related Courses: ${job.relatedCanvasCourses.join(', ')}'),
                Text('Required Skills: ${job.requiredCanvasSkills.join(', ')}'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _applyForJob(BuildContext context, JobOpportunity job, CareerProvider careerProvider) async {
    if (job.primaryApplicationLink != null) {
      final uri = Uri.parse(job.primaryApplicationLink!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open application link')),
        );
      }
    } else {
      // Show application form
      _showApplicationForm(context, job, careerProvider);
    }
  }

  void _showApplicationForm(BuildContext context, JobOpportunity job, CareerProvider careerProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply for ${job.title}'),
        content: const Text('Application form would be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle application submission
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Application submitted successfully!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
} 