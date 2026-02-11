import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/controllers/datastore.dart';
import 'package:gym_tracker/models/exercise_log.dart';
import 'package:gym_tracker/views/exercise_log_list.dart';

import 'exercise_log_entry_form.dart';

class HomeScreen extends StatelessWidget {
  List<ExerciseLog> defaultList = DummyLogs.getDefaultLog();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: ExerciseLogListWidget(exerciseLog: defaultList)),
      floatingActionButton: FloatingActionButton(
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
        child: Icon(Icons.add),
      ),
    );
  }
}
