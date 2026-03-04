import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_tracker/controllers/persistence.dart';
import 'package:gym_tracker/models/exercise.dart';
import 'package:gym_tracker/models/exercise_log.dart';

class FirestoreController implements Persistence {
  static const _logsCollection = 'exercise_logs';
  static const _metaCollection = '_meta';
  static const _counterDocument = 'counters';
  static const _nextLogIdField = 'next_log_id';

  final FirebaseFirestore? _providedFirestore;

  FirestoreController({FirebaseFirestore? firestore})
    : _providedFirestore = firestore;

  FirebaseFirestore get _firestore =>
      _providedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _logs =>
      _firestore.collection(_logsCollection);

  DocumentReference<Map<String, dynamic>> get _counterRef =>
      _firestore.collection(_metaCollection).doc(_counterDocument);

  @override
  Future<void> init() async {
    await _counterRef.set({_nextLogIdField: 1}, SetOptions(merge: true));
  }

  @override
  Future<int?> saveLog(ExerciseLog log) async {
    try {
      return await _firestore.runTransaction<int>((transaction) async {
        final logId = await _nextLogId(transaction);
        final sets = <Map<String, dynamic>>[];
        for (var i = 0; i < log.sets.length; i++) {
          final set = log.sets[i];
          final setId = i + 1;
          set.id = setId;
          sets.add({
            'id': setId,
            'set_order': i,
            'reps': set.reps,
            'weight': set.weight.toDouble(),
          });
        }

        transaction.set(_logs.doc(logId.toString()), {
          'id': logId,
          'exercise_time': Timestamp.fromDate(log.exerciseTime),
          'exercise_name': log.exercise.name,
          'exercise_description': log.exercise.description,
          'body_groups': _encodeBodyGroups(log.exercise.bodyGroups),
          'sets': sets,
        });
        return logId;
      });
    } catch (error) {
      debugPrint('Firestore insert failed: $error');
      return null;
    }
  }

  @override
  Future<void> addSet(int logId, ExerciseSet set) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final logRef = _logs.doc(logId.toString());
        final snapshot = await transaction.get(logRef);
        if (!snapshot.exists) {
          return;
        }

        final data = snapshot.data() ?? <String, dynamic>{};
        final existingSets = _extractSetMaps(data['sets']);
        final nextSetOrder = existingSets.isEmpty
            ? 0
            : existingSets
                      .map((entry) => _asInt(entry['set_order']))
                      .reduce((a, b) => a > b ? a : b) +
                  1;
        final nextSetId = existingSets.isEmpty
            ? 1
            : existingSets
                      .map((entry) => _asInt(entry['id']))
                      .reduce((a, b) => a > b ? a : b) +
                  1;

        set.id = nextSetId;
        existingSets.add({
          'id': nextSetId,
          'set_order': nextSetOrder,
          'reps': set.reps,
          'weight': set.weight.toDouble(),
        });

        transaction.update(logRef, {'sets': existingSets});
      });
    } catch (error) {
      debugPrint('Firestore add set failed: $error');
    }
  }

  @override
  Future<List<ExerciseLog>> getAllLogs() async {
    final snapshot = await _logs.orderBy('id').get();
    return snapshot.docs.map(_mapLog).toList();
  }

  Future<int> _nextLogId(Transaction transaction) async {
    final counterSnapshot = await transaction.get(_counterRef);
    final nextLogId = _asInt(counterSnapshot.data()?[_nextLogIdField], 1);
    transaction.set(_counterRef, {_nextLogIdField: nextLogId + 1});
    return nextLogId;
  }

  ExerciseLog _mapLog(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    final logId = _asInt(data['id']);
    final exercise = Exercise(
      (data['exercise_name'] as String?) ?? '',
      data['exercise_description'] as String?,
      _decodeBodyGroups(data['body_groups']),
    );
    final sets = _extractSetMaps(
      data['sets'],
    )..sort((a, b) => _asInt(a['set_order']).compareTo(_asInt(b['set_order'])));

    return ExerciseLog(
      _parseDateTime(data['exercise_time']),
      exercise,
      sets
          .map(
            (entry) => ExerciseSet(
              _asInt(entry['reps']),
              _asNum(entry['weight']),
              id: _asInt(entry['id']),
            ),
          )
          .toList(),
      id: logId,
    );
  }

  List<String> _encodeBodyGroups(List<BodyGroup> groups) {
    return groups.map((group) => group.name).toList();
  }

  List<BodyGroup> _decodeBodyGroups(Object? value) {
    if (value is! List) {
      return <BodyGroup>[];
    }

    final bodyGroups = <BodyGroup>[];
    for (final entry in value) {
      final groupName = entry?.toString().trim();
      if (groupName == null || groupName.isEmpty) {
        continue;
      }
      for (final group in BodyGroup.values) {
        if (group.name == groupName) {
          bodyGroups.add(group);
          break;
        }
      }
    }
    return bodyGroups;
  }

  List<Map<String, dynamic>> _extractSetMaps(Object? rawSets) {
    if (rawSets is! List) {
      return <Map<String, dynamic>>[];
    }

    return rawSets
        .whereType<Map>()
        .map(
          (entry) => entry.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  int _asInt(Object? value, [int fallback = 0]) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
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
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String && value.isNotEmpty) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
