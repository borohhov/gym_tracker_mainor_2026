import 'package:flutter/material.dart';
import 'package:gym_tracker/controllers/exercise_log_provider.dart';
import 'package:gym_tracker/models/default_exercises.dart';
import 'package:gym_tracker/models/exercise_log.dart';
import 'package:provider/provider.dart';

import '../models/exercise.dart';

class ExerciseLogEntryForm extends StatefulWidget {
  const ExerciseLogEntryForm({super.key});

  @override
  State<ExerciseLogEntryForm> createState() => _ExerciseLogEntryFormState();
}

class _ExerciseLogEntryFormState extends State<ExerciseLogEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  late ExerciseLog exerciseLog;
  Exercise? _selected;

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise label
            Text(
              'Exercise',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<Exercise>(
              value: _selected,
              isExpanded: true,
              decoration: _fieldDecoration(context, 'Exercise name'),
              items: defaultExercises
                  .map(
                    (ex) => DropdownMenuItem<Exercise>(
                  value: ex,
                  child: Text(ex.name),
                ),
              )
                  .toList(),
              validator: (value) {
                if (value == null) return 'Please select an exercise';
                return null;
              },
              onChanged: (value) => setState(() => _selected = value),
            ),

            const SizedBox(height: 16),

            // Sets header
            Text(
              'First set',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: _fieldDecoration(context, 'Reps'),
                    keyboardType: TextInputType.number,
                    controller: _repsController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter reps';
                      }
                      final reps = int.tryParse(value);
                      if (reps == null || reps <= 0) {
                        return 'Reps must be a positive number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: _fieldDecoration(context, 'Weight (kg)'),
                    keyboardType: TextInputType.number,
                    controller: _weightController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter weight';
                      }
                      final weight = num.tryParse(value);
                      if (weight == null || weight < 0) {
                        return 'Weight must be 0 or more';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Full-width primary action (looks way nicer inside dialogs)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;

                  final reps = int.parse(_repsController.text);
                  final weight = num.parse(_weightController.text);

                  exerciseLog = ExerciseLog(
                    DateTime.now(),
                    _selected!,
                    [ExerciseSet(reps, weight)],
                  );

                  Provider.of<ExerciseLogProvider>(context, listen: false)
                      .add(exerciseLog);

                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
