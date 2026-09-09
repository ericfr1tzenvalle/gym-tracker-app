import 'package:gym_tracker_app/models/workout_session_status.dart';
import 'package:gym_tracker_app/models/workout_set.dart';
import '../models/workout_session.dart';

class SessionRepository {
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

  WorkoutSession startOrResumeSession(String workoutId) {
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
      completedAt: null,
      sets: [],
      status: WorkoutSessionStatus.active,
    );

    _sessions.add(session);
    _nextSessionId++;
    return session;
  }

  bool completeSession(String sessionId) {
    final session = findById(sessionId);
    if (session == null || !session.isActive || session.sets.isEmpty) {
      return false;
    }
    session.completedAt = DateTime.now();
    session.status = WorkoutSessionStatus.completed;
    return true;
  }

  bool cancelSession(String sessionId) {
    final session = findById(sessionId);
    if (session == null || !session.isActive) return false;
    session.status = WorkoutSessionStatus.cancelled;
    return true;
  }

  bool removeSession(String sessionId) {
    final session = findById(sessionId);
    if (session == null) return false;
    _sessions.removeWhere((session) => session.id == sessionId);
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
      weight: weight,
      repetitions: repetitions,
      rpe: rpe,
    );

    session.sets.add(createdSet);
    _nextSetId++;
    return createdSet;
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
    return true;
  }

  List<WorkoutSession> findSessionsByWorkoutId(String workoutId) {
    final sessions = _sessions
        .where((session) => session.workoutId == workoutId)
        .toList();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }
}
