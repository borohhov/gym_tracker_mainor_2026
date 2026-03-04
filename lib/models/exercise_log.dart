import 'package:gym_tracker/models/exercise.dart';

class ExerciseLog {
  int? id;
  DateTime exerciseTime;
  Exercise exercise;
  List<ExerciseSet> sets;

  ExerciseLog(this.exerciseTime, this.exercise, this.sets, {this.id});
}

class ExerciseSet {
  int? id;
  int reps;
  num weight;

  ExerciseSet(this.reps, this.weight, {this.id});
}
