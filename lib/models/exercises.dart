import 'package:gym_tracker_app/models/muscle_groups.dart';

class Exercise {
  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final String?  description;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.description,
  });

}

