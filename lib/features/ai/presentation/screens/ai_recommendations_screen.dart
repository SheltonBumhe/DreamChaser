import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/ai_provider.dart';

class AIRecommendationsScreen extends StatelessWidget {
  const AIRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations'),
      ),
      body: Consumer<AIProvider>(
        builder: (context, aiProvider, child) {
          if (aiProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: aiProvider.recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = aiProvider.recommendations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: recommendation.typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      recommendation.typeIcon,
                      color: recommendation.typeColor,
                      size: 20,
                    ),
                  ),
                  title: Text(recommendation.title),
                  subtitle: Text(
                    recommendation.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        recommendation.estimatedTimeString,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: recommendation.priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recommendation.priority.toString().split('.').last,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: recommendation.priorityColor,
                          ),
                        ),
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