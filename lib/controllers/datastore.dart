import 'package:gym_tracker/models/exercise_log.dart';

import '../models/exercise.dart';

class DummyLogs {
  static List<ExerciseLog> getDefaultLog() {
    final Exercise squat = Exercise(
      "Squat",
      "A lower-body compound exercise.",
      [BodyGroup.leg],
    );

    final Exercise benchPress = Exercise(
      "Bench Press",
      "Chest-focused compound lift.",
      [BodyGroup.chest, BodyGroup.arm],
    );

    final List<ExerciseLog> demoLogs = [
      ExerciseLog(
        DateTime(2026, 2, 1, 18, 30),
        squat,
        [
          ExerciseSet(12, 60),
          ExerciseSet(10, 70),
          ExerciseSet(8, 80),
        ],
      ),
      ExerciseLog(
        DateTime(2026, 2, 2, 19, 0),
        benchPress,
        [
          ExerciseSet(10, 40),
          ExerciseSet(8, 50),
          ExerciseSet(6, 60),
        ],
      ),
    ];
    return demoLogs;
  }
}

