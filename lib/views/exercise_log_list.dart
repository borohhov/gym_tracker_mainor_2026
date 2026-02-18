import 'package:flutter/material.dart';
import '../models/exercise_log.dart';

class ExerciseLogListWidget extends StatelessWidget {
  const ExerciseLogListWidget({
    super.key,
    required this.exerciseLog,
  });

  final List<ExerciseLog> exerciseLog;

  @override
  Widget build(BuildContext context) {
    if (exerciseLog.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      itemCount: exerciseLog.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final exLog = exerciseLog[index];

        return Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise name
                Text(
                  exLog.exercise.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                // Sets
                ...exLog.sets.asMap().entries.map((entry) {
                  final setIndex = entry.key + 1;
                  final set = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Set $setIndex',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${set.reps} reps × ${set.weight} kg',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
