import 'package:gym_tracker_app/models/exercises.dart';

import '../models/workouts.dart';
import '../repositories/workout_repository.dart';
import '../repositories/session_repository.dart';

class WorkoutController {
  final WorkoutRepository _workoutRepository;
  final SessionRepository _sessionRepository;

  WorkoutController(this._workoutRepository, this._sessionRepository);

  String? validateWorkoutName(String name, {String? ignoredWorkoutId}) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) return 'Enter a workout name.';
    final alreadyExists = _workoutRepository.findAll().any(
      (workout) =>
          workout.id != ignoredWorkoutId &&
          workout.name.trim().toLowerCase() == normalizedName.toLowerCase(),
    );
    if (alreadyExists) return 'A workout with this name already exists.';
    return null;
  }

  bool createWorkout(String name) {
    final normalizedName = name.trim();
    if (validateWorkoutName(normalizedName) != null) {
      return false;
    }
    return _workoutRepository.add(normalizedName);
  }

  bool updateWorkoutName(String workoutId, String name) {
    if (!canModifyWorkout(workoutId)) return false;
    final normalizedName = name.trim();
    if (validateWorkoutName(normalizedName, ignoredWorkoutId: workoutId) !=
        null) {
      return false;
    }
    return _workoutRepository.updateName(workoutId, normalizedName);
  }

  bool deleteWorkout(String workoutId) {
    if (!canModifyWorkout(workoutId)) return false;
    return _workoutRepository.removeById(workoutId);
  }

  Workout? getWorkoutById(String id) {
    return _workoutRepository.findById(id);
  }

  bool addExerciseToWorkout(
    String workoutId,
    Exercise exercise, {
    required int plannedSets,
    required int plannedRepetitions,
  }) {
    if (!canModifyWorkout(workoutId)) return false;
    if (plannedRepetitions < 1 || plannedSets < 1) return false;
    return _workoutRepository.addExerciseToWorkout(
      workoutId: workoutId,
      exercise: exercise,
      plannedSets: plannedSets,
      plannedRepetitions: plannedRepetitions,
    );
  }

  bool removeExerciseFromWorkout(String workoutId, String exerciseId) {
    if (!canModifyWorkout(workoutId)) {
      return false; // Cannot remove exercise if there's an active session for the workout
    }
    return _workoutRepository.removeExerciseFromWorkout(
      workoutId: workoutId,
      exerciseId: exerciseId,
    );
  }

  List<Workout> getAllWorkouts() {
    return _workoutRepository.findAll();
  }

  bool canModifyWorkout(String workoutId) {
    return !_sessionRepository.hasActiveSessionForWorkout(workoutId);
  }
}
