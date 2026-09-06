import 'package:gym_tracker_app/models/exercises.dart';

import '../models/workouts.dart';
import '../repositories/workout_repository.dart';

class WorkoutController {
  final WorkoutRepository _workoutRepository;

  WorkoutController(this._workoutRepository);

  bool createWorkout(String name) {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
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

  bool addExerciseToWorkout(String workoutId, Exercise exercise) {
    return _workoutRepository.addExerciseToWorkout(
      workoutId: workoutId,
      exercise: exercise,
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
