import 'package:flutter/material.dart';
import 'package:gym_tracker/controllers/exercise_log_provider.dart';
import 'package:gym_tracker/models/exercise_log.dart';
import 'package:gym_tracker/theme/app_theme.dart';
import 'package:gym_tracker/views/exercise_log_list.dart';
import 'package:provider/provider.dart';

import 'exercise_log_entry_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: appColors.screenGradient),
        child: FutureBuilder<List<ExerciseLog>>(
          future: context.watch<ExerciseLogProvider>().getAllLogs(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allLogs = asyncSnapshot.data ?? <ExerciseLog>[];
            final items = _todayLogs(allLogs);
            final setsCount = items.fold<int>(
              0,
              (count, log) => count + log.sets.length,
            );
            final volume = items.fold<num>(
              0,
              (sum, log) => sum + _volumeFor(log),
            );

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Today', style: textTheme.headlineMedium),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert_rounded),
                          splashRadius: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Exercises',
                            value: items.length.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Sets',
                            value: setsCount.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Volume',
                            value: _formatVolume(volume),
                            unit: 'kg',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Text(
                      items.isEmpty
                          ? 'No exercises logged'
                          : '${items.length} exercise${items.length == 1 ? '' : 's'} logged',
                      style: textTheme.titleMedium?.copyWith(
                        color: appColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: items.isEmpty
                          ? const _EmptyStateCard()
                          : ExerciseLogListWidget(
                              exerciseLog: items,
                              onAddSetPressed: (log) {
                                _showAddSetDialog(context, log);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: appColors.accent.withValues(alpha: 0.42),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          tooltip: 'Add Exercise',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Exercise'),
                  content: const ExerciseLogEntryForm(),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  List<ExerciseLog> _todayLogs(List<ExerciseLog> logs) {
    final now = DateTime.now();
    return logs.where((entry) {
      return entry.exerciseTime.year == now.year &&
          entry.exerciseTime.month == now.month &&
          entry.exerciseTime.day == now.day;
    }).toList();
  }

  num _volumeFor(ExerciseLog log) {
    return log.sets.fold<num>(0, (sum, set) => sum + (set.reps * set.weight));
  }

  String _formatVolume(num volume) {
    if (volume >= 1000) {
      final inThousands = volume / 1000;
      final value = inThousands >= 10
          ? inThousands.toStringAsFixed(0)
          : inThousands.toStringAsFixed(1);
      return '${_trimTrailingZero(value)}k';
    }
    if (volume == volume.roundToDouble()) {
      return volume.toStringAsFixed(0);
    }
    return volume.toStringAsFixed(1);
  }

  String _trimTrailingZero(String value) {
    if (value.endsWith('.0')) {
      return value.substring(0, value.length - 2);
    }
    return value;
  }

  Future<void> _showAddSetDialog(BuildContext context, ExerciseLog log) async {
    final logId = log.id;
    if (logId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot add set for this exercise yet.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final repsController = TextEditingController();
    final weightController = TextEditingController();

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text('Add Set - ${log.exercise.name}'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Reps'),
                    keyboardType: TextInputType.number,
                    controller: repsController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter reps';
                      }
                      final reps = int.tryParse(value.trim());
                      if (reps == null || reps <= 0) {
                        return 'Reps must be a positive number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    controller: weightController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter weight';
                      }
                      final weight = num.tryParse(value.trim());
                      if (weight == null || weight < 0) {
                        return 'Weight must be 0 or more';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  final reps = int.parse(repsController.text.trim());
                  final weight = num.parse(weightController.text.trim());
                  await dialogContext.read<ExerciseLogProvider>().addSet(
                    logId,
                    ExerciseSet(reps, weight),
                  );

                  if (!dialogContext.mounted) {
                    return;
                  }
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Save Set'),
              ),
            ],
          );
        },
      );
    } finally {
      repsController.dispose();
      weightController.dispose();
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, this.unit});

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 146,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: appColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              color: appColors.textSecondary,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: appColors.textPrimary,
                  ),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit!,
                    style: textTheme.titleMedium?.copyWith(
                      color: appColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: appColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: appColors.border),
      ),
      padding: const EdgeInsets.all(22),
      child: Center(
        child: Text(
          'Tap + to add your first exercise',
          style: textTheme.titleMedium?.copyWith(
            color: appColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
