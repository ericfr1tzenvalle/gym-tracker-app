class WorkoutSet {
  final String id;
  final String exerciseId;
  final double weight;
  final int repetitions;
  final int? rpe;

  WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.weight,
    required this.repetitions,
    this.rpe,
  });
}
