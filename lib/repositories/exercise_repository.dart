import '../models/exercises.dart';

class ExerciseRepository {
  final List<Exercise> _exercises = [];

  List<Exercise> findAll() => List.unmodifiable(_exercises);

  Exercise? findById(String id) {
    for (final exercise in _exercises) {
      if (exercise.id == id) {
        return exercise;
      }
    }

    return null;
  }

  
  bool add(Exercise exercise) {
    if (findById(exercise.id) != null) {
      return false;
    }

    _exercises.add(exercise);
    return true;
  }

  bool removeById(String id) {
    final exercise = findById(id);
    if (exercise == null) {
      return false;
    }

    _exercises.remove(exercise);
    return true;
  }
}
