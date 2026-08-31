import 'package:gym_tracker_app/models/exercises.dart';
import 'package:gym_tracker_app/models/workout_set.dart';

class Workout {
  final String name;
  final List<Exercise> exercises;
  final bool inProgress;
  final DateTime? date;
  final List<WorkoutSet> sets;

  const Workout({
    required this.name,
    this.exercises = const [],
    this.date,
    this.sets = const [],
    this.inProgress = false
  });


}

