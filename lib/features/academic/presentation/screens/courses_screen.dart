import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/canvas_provider.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: Consumer<CanvasProvider>(
        builder: (context, canvasProvider, child) {
          if (canvasProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: canvasProvider.courses.length,
            itemBuilder: (context, index) {
              final course = canvasProvider.courses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      course.code.split(' ').last,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(course.name),
                  subtitle: Text('${course.instructor} • ${course.credits} credits'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        course.grade.isNotEmpty ? course.grade : 'N/A',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        course.letterGrade,
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