import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:gym_tracker/controllers/persistence.dart';
import 'package:gym_tracker/controllers/sqlite_controller.dart';
import 'package:gym_tracker/models/exercise_log.dart';

class ExerciseLogProvider extends ChangeNotifier {
  Persistence dataSource = SqliteController();

  /// Adds [item] to the log. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  Future<void> add(ExerciseLog item) async {
    await dataSource.saveLog(item);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  Future<List<ExerciseLog>> getAllLogs() async {
    return await dataSource.getAllLogs();
  }
}