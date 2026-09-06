import 'package:gym_tracker_app/models/workout_set.dart';
import 'package:gym_tracker_app/models/workout_session_status.dart';

class WorkoutSession {
  final String id;
  final String workoutId;
  final DateTime startedAt;
  DateTime? completedAt;
  WorkoutSessionStatus status;
  final List<WorkoutSet> sets;

  WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.startedAt,
    this.completedAt,
    this.status = WorkoutSessionStatus.active,
    List<WorkoutSet>? sets,
  }) : sets = sets ?? [];

  bool get isActive => status == WorkoutSessionStatus.active;
}
