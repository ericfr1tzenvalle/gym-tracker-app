import '../models/exercises.dart';
import '../models/muscle_groups.dart';

class ExerciseRepository {
  final List<Exercise> _exercises = [
   Exercise(
      id: '1',
      name: 'Pulldown',
      description: 'Pull the bar down to your chest while keeping your back straight.',
      muscleGroup: MuscleGroup.back,),
    Exercise(
      id: '2',
      name: 'Pulley',
      description: 'Pull the pulley towards your chest while keeping your elbows close to your body.',
      muscleGroup: MuscleGroup.back,),
    Exercise(
      id: '3',
      name: 'Barbell Row',
      description: 'Bend over and pull the barbell towards your stomach while keeping your back straight.',
      muscleGroup: MuscleGroup.back,),
    Exercise(
      id: '4',
      name: 'Biceps Curl',
      description: 'Curl the dumbbells towards your shoulders while keeping your elbows close to your body.',
      muscleGroup: MuscleGroup.arms,),
    Exercise(
      id: '5',
      name: 'Hammer Curl',
      description: 'Curl the dumbbells towards your shoulders with your palms facing each other.',
      muscleGroup: MuscleGroup.arms,),
    Exercise(
      id: '6',
      name: 'Triceps Pushdown',
      description: 'Push the bar down towards your thighs while keeping your elbows close to your body.',
      muscleGroup: MuscleGroup.arms,),
  ];

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
