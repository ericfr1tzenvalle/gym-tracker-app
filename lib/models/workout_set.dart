class WorkoutSet {
  final String exerciseId;
  final double weight;
  final int repetitions;
  final int? rpe;

  const WorkoutSet({
    required this.exerciseId,
    required this.weight,
    required this.repetitions,
    this.rpe,
  });

  
}
