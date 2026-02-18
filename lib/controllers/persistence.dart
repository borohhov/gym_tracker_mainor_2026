import '../models/exercise_log.dart';

abstract class Persistence {
  Future<void> init();
  Future<void> saveLog(ExerciseLog log);
  Future<List<ExerciseLog>> getAllLogs();
}
