import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/career_provider.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Skills'),
      ),
      body: Consumer<CareerProvider>(
        builder: (context, careerProvider, child) {
          if (careerProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: careerProvider.userSkills.length,
            itemBuilder: (context, index) {
              final skill = careerProvider.userSkills[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: skill.levelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      skill.categoryIcon,
                      color: skill.levelColor,
                      size: 20,
                    ),
                  ),
                  title: Text(skill.name),
                  subtitle: Text('${skill.categoryString} • ${skill.levelString}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: skill.levelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      skill.levelString,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: skill.levelColor,
                      ),
                    ),
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