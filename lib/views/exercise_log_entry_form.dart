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
  final List<_SetInputControllers> _setControllers = <_SetInputControllers>[];

  Exercise? _selected;

  @override
  void initState() {
    super.initState();
    _setControllers.add(_SetInputControllers());
  }

  @override
  void dispose() {
    for (final controllers in _setControllers) {
      controllers.dispose();
    }
    super.dispose();
  }

  void _addSetRow() {
    setState(() => _setControllers.add(_SetInputControllers()));
  }

  void _removeSetRow(int index) {
    if (_setControllers.length == 1) {
      return;
    }
    setState(() {
      final controllers = _setControllers.removeAt(index);
      controllers.dispose();
    });
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

  String? _validateReps(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter reps';
    }
    final reps = int.tryParse(value.trim());
    if (reps == null || reps <= 0) {
      return 'Reps must be a positive number';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter weight';
    }
    final weight = num.tryParse(value.trim());
    if (weight == null || weight < 0) {
      return 'Weight must be 0 or more';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exercise',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Exercise>(
                initialValue: _selected,
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
              Row(
                children: [
                  Text(
                    'Sets',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addSetRow,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add set'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._setControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controllers = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == _setControllers.length - 1 ? 0 : 12,
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Set ${index + 1}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            if (_setControllers.length > 1)
                              IconButton(
                                onPressed: () => _removeSetRow(index),
                                icon: const Icon(Icons.delete_outline_rounded),
                                tooltip: 'Remove set',
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: _fieldDecoration(context, 'Reps'),
                                keyboardType: TextInputType.number,
                                controller: controllers.repsController,
                                validator: _validateReps,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                decoration: _fieldDecoration(
                                  context,
                                  'Weight (kg)',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                controller: controllers.weightController,
                                validator: _validateWeight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final sets = _setControllers
                        .map(
                          (controllers) => ExerciseSet(
                            int.parse(controllers.repsController.text.trim()),
                            num.parse(controllers.weightController.text.trim()),
                          ),
                        )
                        .toList();

                    final exerciseLog = ExerciseLog(
                      DateTime.now(),
                      _selected!,
                      sets,
                    );
                    await Provider.of<ExerciseLogProvider>(
                      context,
                      listen: false,
                    ).add(exerciseLog);

                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetInputControllers {
  _SetInputControllers()
    : repsController = TextEditingController(),
      weightController = TextEditingController();

  final TextEditingController repsController;
  final TextEditingController weightController;

  void dispose() {
    repsController.dispose();
    weightController.dispose();
  }
}
