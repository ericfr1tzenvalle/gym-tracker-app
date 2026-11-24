import 'account_database.dart';
import '../data/sample_exercises.dart';

import '../models/exercises.dart';
import '../models/workouts.dart';
import '../models/workout_exercise.dart';

class WorkoutRepository {
  WorkoutRepository(this.store);
  final AccountDatabase store;
  final List<Workout> _workouts = [];
  int _nextWorkoutId = 1;

  Future<void> hydrate() async {
    final plans = await store.rows('planned_exercises');
    for (final row in await store.rows('workouts')) {
      final id = row['id'] as String;
      final items = plans.where((item) => item['workout_id'] == id).toList()
        ..sort(
          (a, b) => (a['position'] as int).compareTo(b['position'] as int),
        );
      _workouts.add(
        Workout(
          id: id,
          name: row['name'] as String,
          exercises: [
            for (final item in items)
              if (sampleExercises
                  .where((e) => e.id == item['exercise_id'])
                  .isNotEmpty)
                WorkoutExercise(
                  exercise: sampleExercises.firstWhere(
                    (e) => e.id == item['exercise_id'],
                  ),
                  plannedSets: item['planned_sets'] as int,
                  plannedRepetitions: item['planned_repetitions'] as int,
                  plannedMinRepetitions: item['planned_min'] as int,
                ),
          ],
        ),
      );
      final numericId = int.tryParse(id);
      if (numericId != null && numericId >= _nextWorkoutId) {
        _nextWorkoutId = numericId + 1;
      }
    }
    // Completed sessions keep their original workout ID after deletion.
    for (final session in await store.rows('sessions')) {
      final id = int.tryParse(session['workout_id'] as String);
      if (id != null && id >= _nextWorkoutId) _nextWorkoutId = id + 1;
    }
  }

  List<Workout> findAll() => List.unmodifiable(_workouts);

  Workout? findById(String id) {
    for (final workout in _workouts) {
      if (workout.id == id) {
        return workout;
      }
    }
    return null;
  }

  int? getNextWorkout(String lastWorkoutId) {
    if (_workouts.isEmpty) return null;

    final nextWorkout =
        _workouts.indexWhere((workout) => workout.id == lastWorkoutId) + 1;
    return nextWorkout % _workouts.length;
  }

  bool _containsExercise(Workout workout, String exerciseId) {
    return workout.exercises.any((item) => item.exercise.id == exerciseId);
  }

  bool add(String name) {
    if (findById(_nextWorkoutId.toString()) != null) {
      return false;
    }

    final workout = Workout(
      id: _nextWorkoutId.toString(),
      name: name,
      exercises: [],
    );
    _workouts.add(workout);
    _nextWorkoutId++;
    store.enqueue((db) async {
      await db.insert('workouts', {
        'uid': store.uid,
        'id': workout.id,
        'name': workout.name,
      });
    });
    return true;
  }

  bool removeById(String workoutId) {
    final workout = findById(workoutId);
    if (workout == null) {
      return false;
    }

    _workouts.remove(workout);
    store.enqueue((db) async {
      await db.delete(
        'planned_exercises',
        where: 'uid = ? AND workout_id = ?',
        whereArgs: [store.uid, workoutId],
      );
      await db.delete(
        'workouts',
        where: 'uid = ? AND id = ?',
        whereArgs: [store.uid, workoutId],
      );
    });
    return true;
  }

  bool updateName(String workoutId, String name) {
    final workout = findById(workoutId);
    if (workout == null) {
      return false;
    }

    workout.name = name;
    store.enqueue((db) async {
      await db.update(
        'workouts',
        {'name': name},
        where: 'uid = ? AND id = ?',
        whereArgs: [store.uid, workoutId],
      );
    });
    return true;
  }

  bool addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
    required int plannedSets,
    required int plannedRepetitions,
    required int plannedMinRepetitions,
  }) {
    final workout = findById(workoutId);
    if (plannedMinRepetitions < 1 ||
        plannedMinRepetitions > plannedRepetitions ||
        plannedRepetitions < 1 ||
        plannedSets < 1 ||
        workout == null ||
        _containsExercise(workout, exercise.id)) {
      return false;
    }

    workout.exercises.add(
      WorkoutExercise(
        exercise: exercise,
        plannedSets: plannedSets,
        plannedRepetitions: plannedRepetitions,
        plannedMinRepetitions: plannedMinRepetitions,
      ),
    );
    final position = workout.exercises.length - 1;
    store.enqueue((db) async {
      await db.insert('planned_exercises', {
        'uid': store.uid,
        'workout_id': workoutId,
        'exercise_id': exercise.id,
        'position': position,
        'planned_sets': plannedSets,
        'planned_repetitions': plannedRepetitions,
        'planned_min': plannedMinRepetitions,
      });
    });
    return true;
  }

  bool updateExercisePlan(
    String workoutId,
    String exerciseId,
    int plannedSets,
    int plannedMinRepetitions,
    int plannedRepetitions,
  ) {
    if (plannedSets < 1 ||
        plannedMinRepetitions < 1 ||
        plannedMinRepetitions > plannedRepetitions) {
      return false;
    }
    final workout = findById(workoutId);
    if (workout == null) return false;
    final index = workout.exercises.indexWhere(
      (item) => item.exercise.id == exerciseId,
    );
    if (index < 0) return false;
    workout.exercises[index] = WorkoutExercise(
      exercise: workout.exercises[index].exercise,
      plannedSets: plannedSets,
      plannedMinRepetitions: plannedMinRepetitions,
      plannedRepetitions: plannedRepetitions,
    );
    store.enqueue((db) async {
      await db.update(
        'planned_exercises',
        {
          'planned_sets': plannedSets,
          'planned_min': plannedMinRepetitions,
          'planned_repetitions': plannedRepetitions,
        },
        where: 'uid = ? AND workout_id = ? AND exercise_id = ?',
        whereArgs: [store.uid, workoutId, exerciseId],
      );
    });
    return true;
  }

  bool reorderExercise(String workoutId, int oldIndex, int newIndex) {
    final workout = findById(workoutId);
    if (workout == null ||
        oldIndex < 0 ||
        oldIndex >= workout.exercises.length ||
        newIndex < 0 ||
        newIndex >= workout.exercises.length) {
      return false;
    }
    workout.exercises.insert(newIndex, workout.exercises.removeAt(oldIndex));
    store.enqueue((db) async {
      for (var i = 0; i < workout.exercises.length; i++) {
        await db.update(
          'planned_exercises',
          {'position': i},
          where: 'uid = ? AND workout_id = ? AND exercise_id = ?',
          whereArgs: [store.uid, workoutId, workout.exercises[i].exercise.id],
        );
      }
    });
    return true;
  }

  bool removeExerciseFromWorkout({
    required String workoutId,
    required String exerciseId,
  }) {
    final workout = findById(workoutId);
    if (workout == null || !_containsExercise(workout, exerciseId)) {
      return false;
    }

    workout.exercises.removeWhere((item) => item.exercise.id == exerciseId);
    store.enqueue((db) async {
      await db.delete(
        'planned_exercises',
        where: 'uid = ? AND workout_id = ? AND exercise_id = ?',
        whereArgs: [store.uid, workoutId, exerciseId],
      );
    });
    return true;
  }
}
