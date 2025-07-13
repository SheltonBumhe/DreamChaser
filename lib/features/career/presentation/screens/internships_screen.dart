import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/career_provider.dart';

class InternshipsScreen extends StatelessWidget {
  const InternshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internships'),
      ),
      body: Consumer<CareerProvider>(
        builder: (context, careerProvider, child) {
          if (careerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: careerProvider.internships.length,
            itemBuilder: (context, index) {
              final internship = careerProvider.internships[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.school, color: Colors.white),
                  ),
                  title: Text(internship.title),
                  subtitle: Text('${internship.company} • ${internship.location}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(internship.matchScore * 100).toInt()}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: internship.matchScoreColor,
                        ),
                      ),
                      Text(
                        internship.duration,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 