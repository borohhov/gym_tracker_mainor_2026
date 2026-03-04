import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/controllers/exercise_log_provider.dart';
import 'package:gym_tracker/controllers/persistence.dart';
import 'package:gym_tracker/models/default_exercises.dart';
import 'package:gym_tracker/models/exercise_log.dart';
import 'package:gym_tracker/theme/app_theme.dart';
import 'package:gym_tracker/views/home.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Home screen renders themed stats and log count', (
    WidgetTester tester,
  ) async {
    final provider = ExerciseLogProvider();
    provider.dataSource = _FakePersistence([
      ExerciseLog(DateTime.now(), defaultExercises.first, [
        ExerciseSet(8, 40),
        ExerciseSet(8, 45),
      ]),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(theme: AppTheme.darkTheme, home: const HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
    expect(find.text('Sets'), findsOneWidget);
    expect(find.textContaining('exercise logged'), findsOneWidget);
    expect(find.text(defaultExercises.first.name), findsOneWidget);
  });
}

class _FakePersistence implements Persistence {
  _FakePersistence(this._logs);

  final List<ExerciseLog> _logs;

  @override
  Future<List<ExerciseLog>> getAllLogs() async {
    return _logs;
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> saveLog(ExerciseLog log) async {
    _logs.add(log);
  }
}
