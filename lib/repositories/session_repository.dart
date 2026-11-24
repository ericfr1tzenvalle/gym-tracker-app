import 'package:gym_tracker_app/models/workout_session_status.dart';
import 'package:gym_tracker_app/models/workout_set.dart';

import '../models/workout_session.dart';
import 'account_database.dart';
import '../models/set_validation.dart';
import '../data/sample_exercises.dart';

class SessionRepository {
  SessionRepository(this.store);
  final AccountDatabase store;

  Future<void> hydrate() async {
    final allSets = await store.rows('recorded_sets');
    for (final row in await store.rows('sessions')) {
      final id = row['id'] as String;
      _sessions.add(
        WorkoutSession(
          id: id,
          workoutId: row['workout_id'] as String,
          workoutName: row['workout_name'] as String,
          startedAt: DateTime.parse(row['started_at'] as String),
          completedAt: row['completed_at'] == null
              ? null
              : DateTime.parse(row['completed_at'] as String),
          status: WorkoutSessionStatus.values.byName(row['status'] as String),
          sets: [
            for (final item in allSets.where(
              (item) => item['session_id'] == id,
            ))
              WorkoutSet(
                id: item['id'] as String,
                exerciseId: item['exercise_id'] as String,
                exerciseName: item['exercise_name'] as String,
                weight: (item['weight'] as num).toDouble(),
                repetitions: item['repetitions'] as int,
                rpe: item['rpe'] as int?,
              ),
          ],
        ),
      );
      final number = int.tryParse(id);
      if (number != null && number >= _nextSessionId) {
        _nextSessionId = number + 1;
      }
    }
    for (final item in allSets) {
      final number = int.tryParse(item['id'] as String);
      if (number != null && number >= _nextSetId) _nextSetId = number + 1;
    }
  }

  final List<WorkoutSession> _sessions = [];
  int _nextSessionId = 1;
  int _nextSetId = 1;

  List<WorkoutSession> findAll() => List.unmodifiable(_sessions);

  WorkoutSession? findById(String id) {
    for (final session in _sessions) {
      if (session.id == id) {
        return session;
      }
    }

    return null;
  }

  WorkoutSession? findActiveSession() {
    for (final session in _sessions) {
      if (session.status == WorkoutSessionStatus.active) {
        return session;
      }
    }
    return null;
  }

  WorkoutSession startOrResumeSession(String workoutId, String workoutName) {
    final activeSession = findActiveSession();
    if (activeSession != null) {
      if (activeSession.workoutId != workoutId) {
        throw StateError(
          'Another workout is already in progress. Resume or end it first.',
        );
      }
      return activeSession;
    }

    final session = WorkoutSession(
      id: _nextSessionId.toString(),
      startedAt: DateTime.now(),
      workoutId: workoutId,
      workoutName: workoutName,
      completedAt: null,
      sets: [],
      status: WorkoutSessionStatus.active,
    );

    _sessions.add(session);
    _nextSessionId++;
    store.enqueue((db) async {
      await db.insert('sessions', {
        'uid': store.uid,
        'id': session.id,
        'workout_id': workoutId,
        'workout_name': workoutName,
        'started_at': session.startedAt.toIso8601String(),
        'status': 'active',
      });
    });
    return session;
  }

  WorkoutSession? getLastCompletedSessionForWorkout(String workoutId) {
    final sessions = _sessions
        .where(
          (session) =>
              session.workoutId == workoutId &&
              session.status == WorkoutSessionStatus.completed,
        )
        .toList();

    if (sessions.isEmpty) return null;

    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions.first;
  }

  WorkoutSession? getLastCompletedSession() {
    final sessions = _sessions
        .where((session) => session.status == WorkoutSessionStatus.completed)
        .toList();

    if (sessions.isEmpty) return null;

    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions.first;
  }

  bool completeSession(String sessionId) {
    final session = findById(sessionId);
    if (session == null || !session.isActive || session.sets.isEmpty) {
      return false;
    }
    session.completedAt = DateTime.now();
    session.status = WorkoutSessionStatus.completed;
    store.enqueue((db) async {
      await db.update(
        'sessions',
        {
          'status': 'completed',
          'completed_at': session.completedAt!.toIso8601String(),
        },
        where: 'uid = ? AND id = ?',
        whereArgs: [store.uid, sessionId],
      );
    });
    return true;
  }

  bool cancelSession(String sessionId) {
    final session = findById(sessionId);
    if (session == null || !session.isActive) return false;
    session.status = WorkoutSessionStatus.cancelled;
    store.enqueue((db) async {
      await db.update(
        'sessions',
        {'status': 'cancelled'},
        where: 'uid = ? AND id = ?',
        whereArgs: [store.uid, sessionId],
      );
    });
    return true;
  }

  bool removeSession(String sessionId) {
    final session = findById(sessionId);
    if (session == null) return false;
    _sessions.removeWhere((session) => session.id == sessionId);
    store.enqueue((db) async {
      await db.delete(
        'recorded_sets',
        where: 'uid = ? AND session_id = ?',
        whereArgs: [store.uid, sessionId],
      );
      await db.delete(
        'sessions',
        where: 'uid = ? AND id = ?',
        whereArgs: [store.uid, sessionId],
      );
    });
    return true;
  }

  WorkoutSet? addSetToSession({
    required String sessionId,
    required String exerciseId,
    required double weight,
    required int repetitions,
    int? rpe,
  }) {
    final session = findById(sessionId);
    if (session == null || !session.isActive) return null;

    final createdSet = WorkoutSet(
      id: _nextSetId.toString(),
      exerciseId: exerciseId,
      exerciseName:
          sampleExercises.where((e) => e.id == exerciseId).firstOrNull?.name ??
          exerciseId,
      weight: weight,
      repetitions: repetitions,
      rpe: rpe,
    );

    session.sets.add(createdSet);
    _nextSetId++;
    store.enqueue((db) async {
      await db.insert('recorded_sets', {
        'uid': store.uid,
        'session_id': sessionId,
        'id': createdSet.id,
        'exercise_id': exerciseId,
        'exercise_name': createdSet.exerciseName,
        'weight': weight,
        'repetitions': repetitions,
        'rpe': rpe,
      });
    });
    return createdSet;
  }

  bool updateSet({
    required String sessionId,
    required String setId,
    required double weight,
    required int repetitions,
  }) {
    if (!SetValidation.validWeight(weight) ||
        !SetValidation.validRepetitions(repetitions)) {
      return false;
    }
    final session = findById(sessionId);
    if (session == null || !session.isActive) return false;
    final index = session.sets.indexWhere((set) => set.id == setId);
    if (index < 0) return false;
    final old = session.sets[index];
    session.sets[index] = WorkoutSet(
      id: old.id,
      exerciseId: old.exerciseId,
      exerciseName: old.exerciseName,
      weight: weight,
      repetitions: repetitions,
      rpe: old.rpe,
    );
    store.enqueue((db) async {
      await db.update(
        'recorded_sets',
        {'weight': weight, 'repetitions': repetitions},
        where: 'uid = ? AND session_id = ? AND id = ?',
        whereArgs: [store.uid, sessionId, setId],
      );
    });
    return true;
  }

  List<WorkoutSet> getSetsFromSession(String sessionId) {
    final session = findById(sessionId);
    if (session == null) return [];
    return List.unmodifiable(session.sets);
  }

  bool removeSetFromSession({
    required String sessionId,
    required String setId,
  }) {
    final session = findById(sessionId);
    if (session == null || !session.isActive) {
      return false;
    }

    final setExists = session.sets.any((workoutSet) => workoutSet.id == setId);
    if (!setExists) {
      return false;
    }

    session.sets.removeWhere((workoutSet) => workoutSet.id == setId);
    store.enqueue((db) async {
      await db.delete(
        'recorded_sets',
        where: 'uid = ? AND session_id = ? AND id = ?',
        whereArgs: [store.uid, sessionId, setId],
      );
    });
    return true;
  }

  List<WorkoutSession> findSessionsByWorkoutId(String workoutId) {
    final sessions = _sessions
        .where((session) => session.workoutId == workoutId)
        .toList();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  bool hasActiveSessionForWorkout(String workoutId) {
    final activeSession = findActiveSession();

    return activeSession?.workoutId == workoutId;
  }
}
