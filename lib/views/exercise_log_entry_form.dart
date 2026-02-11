import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/models/default_exercises.dart';

import '../models/exercise.dart';

class ExerciseLogEntryForm extends StatefulWidget {
  const ExerciseLogEntryForm({super.key});

  @override
  State<ExerciseLogEntryForm> createState() => _ExerciseLogEntryFormState();
}

class _ExerciseLogEntryFormState extends State<ExerciseLogEntryForm> {
  Exercise? _selected; // adjust type to whatever your list contains

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ prevents dialog overflow
        children: [
          DropdownButtonFormField<Exercise>(
            value: _selected,
            isExpanded: true,
            items: defaultExercises
                .map(
                  (ex) => DropdownMenuItem<Exercise>(
                value: ex,              // ✅ IMPORTANT
                child: Text(ex.name),
              ),
            )
                .toList(),
            onChanged: (value) {
              setState(() => _selected = value);
            },
          ),
        ],
      ),
    );
  }
}

