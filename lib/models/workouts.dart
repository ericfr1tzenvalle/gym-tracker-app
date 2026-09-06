import 'package:gym_tracker_app/models/exercises.dart';

class Workout {
  final String id;
  final String name;
  final List<Exercise> exercises;

  Workout({required this.id, required this.name, List<Exercise>? exercises})
    : exercises = exercises ?? [];
}
