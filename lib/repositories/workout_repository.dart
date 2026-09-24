import '../data/sample_exercises.dart';

import '../models/exercises.dart';
import '../models/workouts.dart';
import '../models/workout_exercise.dart';

class WorkoutRepository {
  final List<Workout> _workouts = [
    Workout(
      id: '1',
      name: 'Push Day',
      exercises: sampleExercises
          .where((exercise) => {'6', '7', '8'}.contains(exercise.id))
          .map(
            (exercise) => WorkoutExercise(
              exercise: exercise,
              plannedSets: 3,
              plannedRepetitions: 10,
            ),
          )
          .toList(),
    ),
    Workout(
      id: '2',
      name: 'Pull Day',
      exercises: sampleExercises
          .where((exercise) => {'1', '2', '3', '4', '5'}.contains(exercise.id))
          .map(
            (exercise) => WorkoutExercise(
              exercise: exercise,
              plannedSets: 3,
              plannedRepetitions: 10,
            ),
          )
          .toList(),
    ),
    Workout(
      id: '3',
      name: 'Leg Day',
      exercises: sampleExercises
          .where((exercise) => {'9', '10', '11'}.contains(exercise.id))
          .map(
            (exercise) => WorkoutExercise(
              exercise: exercise,
              plannedSets: 3,
              plannedRepetitions: 10,
            ),
          )
          .toList(),
    ),
  ];
  int _nextWorkoutId = 4;

  List<Workout> findAll() => List.unmodifiable(_workouts);

  Workout? findById(String id) {
    for (final workout in _workouts) {
      if (workout.id == id) {
        return workout;
      }
    }
    return null;
  }

  int? getNextWorkout(String lastWorkoutId) {
    if (_workouts.isEmpty) return null;

    final nextWorkout =
        _workouts.indexWhere((workout) => workout.id == lastWorkoutId) + 1;
    return nextWorkout % _workouts.length;
  }

  bool _containsExercise(Workout workout, String exerciseId) {
    return workout.exercises.any((item) => item.exercise.id == exerciseId);
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

  bool updateName(String workoutId, String name) {
    final workout = findById(workoutId);
    if (workout == null) {
      return false;
    }

    workout.name = name;
    return true;
  }

  bool addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
    required int plannedSets,
    required int plannedRepetitions,
  }) {
    final workout = findById(workoutId);
    if (plannedRepetitions < 1 ||
        plannedSets < 1 ||
        workout == null ||
        _containsExercise(workout, exercise.id)) {
      return false;
    }

    workout.exercises.add(
      WorkoutExercise(
        exercise: exercise,
        plannedSets: plannedSets,
        plannedRepetitions: plannedRepetitions,
      ),
    );
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

    workout.exercises.removeWhere((item) => item.exercise.id == exerciseId);
    return true;
  }
}
