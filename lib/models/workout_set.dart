class WorkoutSet {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final double weight;
  final int repetitions;
  final int? rpe;

  WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.repetitions,
    this.rpe,
  });
}
