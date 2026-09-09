import 'package:gym_tracker_app/models/exercises.dart';

import '../models/workouts.dart';
import '../repositories/workout_repository.dart';

class WorkoutController {
  final WorkoutRepository _workoutRepository;

  WorkoutController(this._workoutRepository);

  String? validateWorkoutName(String name) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) return 'Enter a workout name.';
    final alreadyExists = _workoutRepository.findAll().any(
      (workout) =>
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

  bool deleteWorkout(String workoutId) {
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
    if (plannedRepetitions < 1 || plannedSets < 1) return false;
    return _workoutRepository.addExerciseToWorkout(
      workoutId: workoutId,
      exercise: exercise,
      plannedSets: plannedSets,
      plannedRepetitions: plannedRepetitions,
    );
  }

  bool removeExerciseFromWorkout(String workoutId, String exerciseId) {
    return _workoutRepository.removeExerciseFromWorkout(
      workoutId: workoutId,
      exerciseId: exerciseId,
    );
  }

  List<Workout> getAllWorkouts() {
    return _workoutRepository.findAll();
  }
}
