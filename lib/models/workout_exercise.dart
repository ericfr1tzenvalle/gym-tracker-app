import 'exercises.dart';

class WorkoutExercise {
  final Exercise exercise;
  final int plannedSets;
  final int plannedRepetitions;

  WorkoutExercise({
    required this.exercise,
    required this.plannedSets,
    required this.plannedRepetitions,
  }) {
    if (plannedRepetitions < 1) {
      throw ArgumentError.value(
        plannedRepetitions,
        'plannedRepetitions',
        'Must be at least 1.',
      );
    }
    if (plannedSets < 1) {
      throw ArgumentError.value(
        plannedSets,
        'plannedSets',
        'Must be at least 1.',
      );
    }
  }
}
