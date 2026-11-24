import 'exercises.dart';

class WorkoutExercise {
  final Exercise exercise;
  final int plannedSets;
  final int plannedRepetitions;
  final int plannedMinRepetitions;

  WorkoutExercise({
    required this.exercise,
    required this.plannedSets,
    required this.plannedRepetitions,
    int? plannedMinRepetitions,
  }) : plannedMinRepetitions = plannedMinRepetitions ?? plannedRepetitions {
    if (this.plannedMinRepetitions < 1 ||
        this.plannedMinRepetitions > plannedRepetitions) {
      throw ArgumentError.value(
        plannedMinRepetitions,
        "plannedMinRepetitions",
        "Must be between 1 and the maximum.",
      );
    }
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
