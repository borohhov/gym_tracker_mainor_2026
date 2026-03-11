import 'package:flutter/cupertino.dart';
import 'package:gym_tracker/controllers/firestore_controller.dart';
import 'package:gym_tracker/controllers/persistence.dart';
import 'package:gym_tracker/models/exercise_log.dart';

import 'package:flutter/foundation.dart';
import 'package:gym_tracker/controllers/firestore_controller.dart';
import 'package:gym_tracker/controllers/persistence.dart';
import 'package:gym_tracker/controllers/sqlite_controller.dart';
import 'package:gym_tracker/models/exercise_log.dart';

class ExerciseLogProvider extends ChangeNotifier {
  Persistence _dataSource;
  bool _initialized = false;

  ExerciseLogProvider({Persistence? dataSource})
      : _dataSource = dataSource ?? SqliteController();

  Persistence get dataSource => _dataSource;

  bool get isUsingFirestore => _dataSource is FirestoreController;

  Future<void> init() async {
    if (_initialized) return;
    await _dataSource.init();
    _initialized = true;
  }

  Future<void> useGuestMode() async {
    _dataSource = SqliteController();
    _initialized = false;
    await init();
    notifyListeners();
  }

  Future<void> useAuthenticatedMode(String uid) async {
    _dataSource = FirestoreController(userId: uid);
    _initialized = false;
    await init();
    notifyListeners();
  }

  Future<void> add(ExerciseLog item) async {
    await init();
    final logId = await _dataSource.saveLog(item);
    item.id = logId;
    notifyListeners();
  }

  Future<void> addSet(int logId, ExerciseSet set) async {
    await init();
    await _dataSource.addSet(logId, set);
    notifyListeners();
  }

  Future<List<ExerciseLog>> getAllLogs() async {
    await init();
    return _dataSource.getAllLogs();
  }
}