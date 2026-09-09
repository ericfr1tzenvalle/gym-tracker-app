import 'package:gym_tracker_app/repositories/session_repository.dart';

import '../models/workout_session.dart';
import '../models/workout_session_progress.dart';
import '../models/workout_session_status.dart';
import '../models/workout_set.dart';
import '../repositories/workout_repository.dart';

class WorkoutSessionController {
  final SessionRepository _sessionRepository;
  final WorkoutRepository _workoutRepository;

  WorkoutSessionController(this._sessionRepository, this._workoutRepository);

  WorkoutSession startOrResumeSession(String workoutId) {
    if (_sessionRepository.findActiveSession() != null) {
      return _sessionRepository.startOrResumeSession(workoutId);
    }

    final workout = _workoutRepository.findById(workoutId);
    if (workout == null || workout.exercises.isEmpty) {
      throw Exception('Workout not found or has no exercises.');
    }
    return _sessionRepository.startOrResumeSession(workoutId);
  }

  bool completeSession(String sessionId) {
    final session = _sessionRepository.findById(sessionId);
    if (session == null || session.sets.isEmpty) return false;
    return _sessionRepository.completeSession(sessionId);
  }

  bool cancelSession(String sessionId) {
    return _sessionRepository.cancelSession(sessionId);
  }

  WorkoutSet? addSetToSession({
    required String sessionId,
    required String exerciseId,
    required double weight,
    required int repetitions,
    int? rpe,
  }) {
    final invalidRpe = rpe != null && (rpe < 1 || rpe > 10);
    if (exerciseId.trim().isEmpty ||
        !weight.isFinite ||
        weight <= 0 ||
        repetitions <= 0 ||
        invalidRpe) {
      return null;
    }

    final progress = getSessionProgress(sessionId);
    if (progress == null || !progress.session.isActive) return null;

    final workout = progress.workout;
    if (workout == null) return null;
    final exerciseIndex = workout.exercises.indexWhere(
      (item) => item.exercise.id == exerciseId,
    );
    if (exerciseIndex == -1) return null;

    final plannedSets = workout.exercises[exerciseIndex].plannedSets;
    final registeredSets = progress.session.sets
        .where((set) => set.exerciseId == exerciseId)
        .length;
    if (registeredSets >= plannedSets) return null;

    final registeredSet = _sessionRepository.addSetToSession(
      sessionId: sessionId,
      exerciseId: exerciseId,
      weight: weight,
      repetitions: repetitions,
      rpe: rpe,
    );
    if (registeredSet == null) return null;

    final updatedProgress = getSessionProgress(sessionId)!;
    if (updatedProgress.completedExercises == workout.exercises.length) {
      _sessionRepository.completeSession(sessionId);
    }
    return registeredSet;
  }

  WorkoutSessionProgress? getSessionProgress(String sessionId) {
    final session = _sessionRepository.findById(sessionId);
    if (session == null) return null;

    final workout = _workoutRepository.findById(session.workoutId);
    final setsByExercise = <String, int>{};
    final lastSetsByExercise = <String, WorkoutSet>{};
    var totalVolume = 0.0;
    for (final set in session.sets) {
      setsByExercise.update(
        set.exerciseId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      lastSetsByExercise[set.exerciseId] = set;
      totalVolume += set.weight * set.repetitions;
    }

    var totalPlannedSets = 0;
    var completedExercises = 0;
    var exerciseIndex = -1;
    if (workout != null) {
      for (var index = 0; index < workout.exercises.length; index++) {
        final item = workout.exercises[index];
        totalPlannedSets += item.plannedSets;
        final registeredSets = setsByExercise[item.exercise.id] ?? 0;
        if (registeredSets >= item.plannedSets) {
          completedExercises++;
        } else if (session.isActive && exerciseIndex == -1) {
          exerciseIndex = index;
        }
      }
    }

    final currentExercise = exerciseIndex == -1
        ? null
        : workout!.exercises[exerciseIndex];
    final lastSet = currentExercise == null
        ? null
        : lastSetsByExercise[currentExercise.exercise.id];
    return WorkoutSessionProgress(
      session: session,
      workout: workout,
      currentExercise: currentExercise,
      lastSetForCurrentExercise: lastSet,
      suggestedSet: currentExercise == null
          ? null
          : lastSet ?? _findPreviousSet(session, currentExercise.exercise.id),
      exerciseIndex: exerciseIndex,
      currentExerciseCompletedSets: currentExercise == null
          ? 0
          : setsByExercise[currentExercise.exercise.id] ?? 0,
      totalPlannedSets: totalPlannedSets,
      totalCompletedSets: session.sets.length,
      completedExercises: completedExercises,
      totalVolume: totalVolume,
    );
  }

  WorkoutSet? _findPreviousSet(WorkoutSession session, String exerciseId) {
    final previousSessions =
        _sessionRepository
            .findSessionsByWorkoutId(session.workoutId)
            .where(
              (previous) =>
                  previous.id != session.id &&
                  previous.status == WorkoutSessionStatus.completed &&
                  previous.completedAt != null &&
                  !previous.completedAt!.isAfter(session.startedAt),
            )
            .toList()
          ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

    for (final previous in previousSessions) {
      for (final set in previous.sets.reversed) {
        if (set.exerciseId == exerciseId) return set;
      }
    }
    return null;
  }

  WorkoutSession? getSessionById(String sessionId) {
    return _sessionRepository.findById(sessionId);
  }

  WorkoutSession? getActiveSession() {
    return _sessionRepository.findActiveSession();
  }

  List<WorkoutSession> getAllSessions() {
    return _sessionRepository.findAll();
  }

  List<WorkoutSession> getSessionsByWorkoutId(String workoutId) {
    return _sessionRepository.findSessionsByWorkoutId(workoutId);
  }

  List<WorkoutSet> getSetsFromSession(String sessionId) {
    return _sessionRepository.getSetsFromSession(sessionId);
  }

  bool removeSetFromSession({
    required String sessionId,
    required String setId,
  }) {
    return _sessionRepository.removeSetFromSession(
      sessionId: sessionId,
      setId: setId,
    );
  }

  bool deleteSession(String sessionId) {
    return _sessionRepository.removeSession(sessionId);
  }
}
