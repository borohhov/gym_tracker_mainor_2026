import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:gym_tracker/models/exercise_log.dart';

class ExerciseLogProvider extends ChangeNotifier {
  /// Internal, private state of the cart.
  final List<ExerciseLog> _exercises = [];

  /// An unmodifiable view of the items in the cart.
  UnmodifiableListView<ExerciseLog> get items => UnmodifiableListView(_exercises);

  /// Adds [item] to the log. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void add(ExerciseLog item) {
    _exercises.add(item);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  /// Removes all items from the cart.
  void removeAll() {
    _exercises.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}