import 'workout_exercise.dart';

class Workout {
  final String id;
  String name;
  final List<WorkoutExercise> exercises;

  Workout({
    required this.id,
    required this.name,
    List<WorkoutExercise>? exercises,
  }) : exercises = exercises ?? [];
}
