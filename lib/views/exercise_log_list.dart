import 'package:flutter/material.dart';
import 'package:gym_tracker/theme/app_theme.dart';
import '../models/exercise_log.dart';

class ExerciseLogListWidget extends StatelessWidget {
  const ExerciseLogListWidget({
    super.key,
    required this.exerciseLog,
    required this.onAddSetPressed,
  });

  final List<ExerciseLog> exerciseLog;
  final ValueChanged<ExerciseLog> onAddSetPressed;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    if (exerciseLog.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      itemCount: exerciseLog.length,
      separatorBuilder: (_, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final exLog = exerciseLog[index];

        return Container(
          decoration: BoxDecoration(
            color: appColors.surface.withValues(alpha: 0.94),
            border: Border.all(color: appColors.border),
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        exLog.exercise.name,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: appColors.textPrimary,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => onAddSetPressed(exLog),
                      icon: Icon(
                        Icons.add_rounded,
                        color: appColors.accent,
                        size: 28,
                      ),
                      label: Text(
                        'Add Set',
                        style: textTheme.titleMedium?.copyWith(
                          color: appColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        minimumSize: const Size(44, 44),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...exLog.sets.asMap().entries.map((entry) {
                final setIndex = entry.key + 1;
                final set = entry.value;
                final isLast = setIndex == exLog.sets.length;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 17,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Set $setIndex',
                              style: textTheme.titleMedium?.copyWith(
                                color: appColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${set.reps} reps',
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 38 / 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '  x  ',
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 36 / 2,
                              color: appColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${_formatWeight(set.weight)} kg',
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 38 / 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: appColors.border.withValues(alpha: 0.35),
                      ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _formatWeight(num weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toStringAsFixed(0);
    }
    return weight.toStringAsFixed(1);
  }
}
