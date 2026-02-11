import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/models/default_exercises.dart';
import 'package:gym_tracker/models/exercise_log.dart';

import '../models/exercise.dart';

class ExerciseLogEntryForm extends StatefulWidget {
  const ExerciseLogEntryForm({super.key});

  @override
  State<ExerciseLogEntryForm> createState() => _ExerciseLogEntryFormState();
}

class _ExerciseLogEntryFormState extends State<ExerciseLogEntryForm> {
  late ExerciseLog exerciseLog;
  Exercise? _selected;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Exercise>(
            value: _selected,
            isExpanded: true,
            items: defaultExercises
                .map(
                  (ex) => DropdownMenuItem<Exercise>(
                    value: ex,
                    child: Text(ex.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selected = value;
                exerciseLog.exercise = _selected!;
              });
            },
          ),
          Text('First set'),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) != null) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Weight'),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) != null) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
