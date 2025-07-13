import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/canvas_provider.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      body: Consumer<CanvasProvider>(
        builder: (context, canvasProvider, child) {
          if (canvasProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: canvasProvider.assignments.length,
            itemBuilder: (context, index) {
              final assignment = canvasProvider.assignments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                  title: Text(assignment.title),
                  subtitle: Text(
                    '${assignment.timeUntilDueString} • ${assignment.priorityString} Priority',
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      // TODO: Mark as complete
                    },
                    icon: Icon(
                      assignment.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                      color: assignment.isCompleted ? Colors.green : null,
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