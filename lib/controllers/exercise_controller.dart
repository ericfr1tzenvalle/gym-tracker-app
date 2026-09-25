import 'package:flutter/animation.dart';
import 'package:gym_tracker_app/repositories/exercise_repository.dart';
import '../models/exercises.dart';

class ExerciseController {
  ExerciseController(this._exerciseRepository);

  final ExerciseRepository _exerciseRepository;

  List<Exercise> getAllExercises() {
    return _exerciseRepository.findAll();
  }
}
