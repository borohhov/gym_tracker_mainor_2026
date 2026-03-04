import 'package:flutter/cupertino.dart';
import 'package:gym_tracker/controllers/firestore_controller.dart';
import 'package:gym_tracker/controllers/persistence.dart';
import 'package:gym_tracker/models/exercise_log.dart';

class ExerciseLogProvider extends ChangeNotifier {
  Persistence dataSource;

  ExerciseLogProvider({Persistence? dataSource})
    : dataSource = dataSource ?? FirestoreController();

  /// Adds [item] to the log. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  Future<void> add(ExerciseLog item) async {
    final logId = await dataSource.saveLog(item);
    item.id = logId;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  Future<void> addSet(int logId, ExerciseSet set) async {
    await dataSource.addSet(logId, set);
    notifyListeners();
  }

  Future<List<ExerciseLog>> getAllLogs() async {
    return await dataSource.getAllLogs();
  }
}
