import 'workout_exercise.dart';
import 'workout_session.dart';
import 'workout_set.dart';
import 'workouts.dart';

class WorkoutSessionProgress {
  final WorkoutSession session;
  final Workout? workout;
  final WorkoutExercise? currentExercise;
  final WorkoutSet? lastSetForCurrentExercise;
  final WorkoutSet? suggestedSet;
  final int exerciseIndex;
  final int currentExerciseCompletedSets;
  final int totalPlannedSets;
  final int totalCompletedSets;
  final int completedExercises;
  final double totalVolume;

  const WorkoutSessionProgress({
    required this.session,
    required this.workout,
    required this.currentExercise,
    required this.lastSetForCurrentExercise,
    required this.suggestedSet,
    required this.exerciseIndex,
    required this.currentExerciseCompletedSets,
    required this.totalPlannedSets,
    required this.totalCompletedSets,
    required this.completedExercises,
    required this.totalVolume,
  });
}
