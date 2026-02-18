import 'package:flutter/foundation.dart';
import 'package:gym_tracker/controllers/persistence.dart';
import 'package:gym_tracker/models/exercise.dart';
import 'package:gym_tracker/models/exercise_log.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class SqliteController implements Persistence {
  static const _dbName = 'gym_tracker.db';
  static const _dbVersion = 1;
  static const _logsTable = 'exercise_logs';
  static const _setsTable = 'exercise_sets';

  Future<Database>? _databaseFuture;

  @override
  Future<void> init() async {
    _databaseFuture ??= _openDatabase();
    await _databaseFuture;
  }

  @override
  Future<void> saveLog(ExerciseLog log) async {
    final db = await _database();
    try {
      await db.transaction((txn) async {
        final logId = await txn.insert(_logsTable, {
          'exercise_time': log.exerciseTime.toIso8601String(),
          'exercise_name': log.exercise.name,
          'exercise_description': log.exercise.description,
          'body_groups': _encodeBodyGroups(log.exercise.bodyGroups),
        });

        for (var i = 0; i < log.sets.length; i++) {
          final set = log.sets[i];
          await txn.insert(_setsTable, {
            'log_id': logId,
            'set_order': i,
            'reps': set.reps,
            'weight': set.weight.toDouble(),
          });
        }
      });
    } catch (error) {
      debugPrint('SQLite insert failed: $error');
    }
  }

  @override
  Future<List<ExerciseLog>> getAllLogs() async {
    final db = await _database();
    return _loadAllFromDb(db);
  }

  Future<Database> _database() async {
    _databaseFuture ??= _openDatabase();
    return _databaseFuture!;
  }

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE $_logsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercise_time TEXT NOT NULL,
            exercise_name TEXT NOT NULL,
            exercise_description TEXT,
            body_groups TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE $_setsTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            log_id INTEGER NOT NULL,
            set_order INTEGER NOT NULL,
            reps INTEGER NOT NULL,
            weight REAL NOT NULL,
            FOREIGN KEY(log_id) REFERENCES $_logsTable(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<List<ExerciseLog>> _loadAllFromDb(Database db) async {
    final logRows = await db.query(_logsTable, orderBy: 'id ASC');
    final setRows = await db.query(
      _setsTable,
      orderBy: 'log_id ASC, set_order ASC',
    );

    final setsByLogId = <int, List<ExerciseSet>>{};
    for (final setRow in setRows) {
      final logId = _asInt(setRow['log_id']);
      final reps = _asInt(setRow['reps']);
      final weight = _asNum(setRow['weight']);
      setsByLogId.putIfAbsent(logId, () => []).add(ExerciseSet(reps, weight));
    }

    return logRows.map((logRow) {
      final logId = _asInt(logRow['id']);
      final exercise = Exercise(
        (logRow['exercise_name'] as String?) ?? '',
        logRow['exercise_description'] as String?,
        _decodeBodyGroups((logRow['body_groups'] as String?) ?? ''),
      );
      return ExerciseLog(
        _parseDateTime(logRow['exercise_time']),
        exercise,
        setsByLogId[logId] ?? <ExerciseSet>[],
      );
    }).toList();
  }

  String _encodeBodyGroups(List<BodyGroup> groups) {
    return groups.map((group) => group.name).join(',');
  }

  List<BodyGroup> _decodeBodyGroups(String encoded) {
    if (encoded.isEmpty) {
      return <BodyGroup>[];
    }

    final bodyGroups = <BodyGroup>[];
    for (final token in encoded.split(',')) {
      for (final group in BodyGroup.values) {
        if (group.name == token.trim()) {
          bodyGroups.add(group);
          break;
        }
      }
    }
    return bodyGroups;
  }

  int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  num _asNum(Object? value) {
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value) ?? 0;
    }
    return 0;
  }

  DateTime _parseDateTime(Object? value) {
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
