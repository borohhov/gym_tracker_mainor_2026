import '../models/exercise_log.dart';

abstract class Persistence {
  Future<void> init();
  Future<int?> saveLog(ExerciseLog log);
  Future<void> addSet(int logId, ExerciseSet set);
  Future<List<ExerciseLog>> getAllLogs();
}
