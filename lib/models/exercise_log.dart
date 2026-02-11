import 'package:gym_tracker/models/exercise.dart';

class ExerciseLog {
  DateTime exerciseTime;
  Exercise exercise;
  List<ExerciseSet> sets;

  ExerciseLog(this.exerciseTime, this.exercise, this.sets);
}

class ExerciseSet {
  int reps;
  num weight;

  ExerciseSet(this.reps, this.weight);
}