import '../models/exercises.dart';
import '../models/workouts.dart';

class WorkoutRepository {
  final List<Workout> _workouts = [];
  int _nextWorkoutId = 1;

  List<Workout> findAll() => List.unmodifiable(_workouts);

  Workout? findById(String id) {
    for (final workout in _workouts) {
      if (workout.id == id) {
        return workout;
      }
    }

    return null;
  }

  bool _containsExercise(Workout workout, String exerciseId) {
    return workout.exercises.any((exercise) => exercise.id == exerciseId);
  }

  bool add(String name) {
    if (findById(_nextWorkoutId.toString()) != null) {
      return false;
    }

    final workout = Workout(
      id: _nextWorkoutId.toString(),
      name: name,
      exercises: [],
    );
    _workouts.add(workout);
    _nextWorkoutId++;
    return true;
  }

  bool removeById(String workoutId) {
    final workout = findById(workoutId);
    if (workout == null) {
      return false;
    }

    _workouts.remove(workout);
    return true;
  }

  bool addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
  }) {
    final workout = findById(workoutId);
    if (workout == null || _containsExercise(workout, exercise.id)) {
      return false;
    }

    workout.exercises.add(exercise);
    return true;
  }

  bool removeExerciseFromWorkout({
    required String workoutId,
    required String exerciseId,
  }) {
    final workout = findById(workoutId);
    if (workout == null || !_containsExercise(workout, exerciseId)) {
      return false;
    }

    workout.exercises.removeWhere((exercise) => exercise.id == exerciseId);
    return true;
  }
}
