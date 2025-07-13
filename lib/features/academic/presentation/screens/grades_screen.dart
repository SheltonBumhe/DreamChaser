import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/canvas_provider.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades'),
      ),
      body: Consumer<CanvasProvider>(
        builder: (context, canvasProvider, child) {
          if (canvasProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: canvasProvider.grades.length,
            itemBuilder: (context, index) {
              final grade = canvasProvider.grades[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      grade.letterGrade,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(grade.courseName),
                  subtitle: Text('${grade.semester} • ${grade.credits} credits'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${grade.grade.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'GPA: ${grade.gradePoints}',
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