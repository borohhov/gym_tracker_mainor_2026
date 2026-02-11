import 'package:flutter/material.dart';

import '../models/exercise_log.dart';

class ExerciseLogListWidget extends StatelessWidget {
  const ExerciseLogListWidget({super.key, required this.exerciseLog});

  final List<ExerciseLog> exerciseLog;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: exerciseLog
          .map(
            (exLog) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exLog.exercise.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                Column(children: exLog.sets.map((set) => Row(children: [
                  Text('reps:' + set.reps.toString() + ' x ' + set.weight.toString() + 'kg'),

                ])).toList()),
              ],
            ),
          )
          .toList(),
    );
  }
}
