import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/ai_provider.dart';

class AIInsightsScreen extends StatelessWidget {
  const AIInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
      ),
      body: Consumer<AIProvider>(
        builder: (context, aiProvider, child) {
          if (aiProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: aiProvider.insights.length,
            itemBuilder: (context, index) {
              final insight = aiProvider.insights[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                  title: Text(insight.title),
                  subtitle: Text(
                    insight.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    insight.timeAgo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
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