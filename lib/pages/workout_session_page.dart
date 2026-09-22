import 'package:flutter/material.dart';
import '../widgets/glass_surface.dart';
import 'package:gym_tracker_app/widgets/workout_set_card.dart';
import '../controllers/workout_session_controller.dart';
import '../widgets/app_logo.dart';
import '../controllers/workout_controller.dart';

class WorkoutSessionPage extends StatefulWidget {
  final WorkoutSessionController workoutSessionController;
  final WorkoutController workoutController;
  final String sessionId;
  const WorkoutSessionPage({
    super.key,
    required this.workoutSessionController,
    required this.sessionId,
    required this.workoutController,
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  @override
  Widget build(BuildContext context) {
    final session = widget.workoutSessionController.getSessionById(
      widget.sessionId,
    );
    if (session == null) {
      return Scaffold(
        appBar: GlassAppBar(title: const AppLogo()),
        body: const Center(child: Text('Session not found')),
      );
    }

    final workout = widget.workoutController.getWorkoutById(session.workoutId);
    if (workout == null) {
      return Scaffold(
        appBar: GlassAppBar(title: const AppLogo()),
        body: const Center(child: Text('Workout not found')),
      );
    }

    if (workout.exercises.isEmpty) {
      return Scaffold(
        appBar: GlassAppBar(title: const AppLogo()),
        body: const Center(child: Text('This workout has no exercises.')),
      );
    }

    final sessionSets = widget.workoutSessionController.getSetsFromSession(
      widget.sessionId,
    );
    final exerciseIndex = workout.exercises.indexWhere((item) {
      final registeredSets = sessionSets
          .where((set) => set.exerciseId == item.exercise.id)
          .length;
      return registeredSets < item.plannedSets;
    });

    if (exerciseIndex == -1) {
      return Scaffold(
        appBar: GlassAppBar(title: const AppLogo()),
        body: const Center(child: Text('Workout done!')),
      );
    }

    final workoutExercise = workout.exercises[exerciseIndex];
    final completedSets = sessionSets
        .where((set) => set.exerciseId == workoutExercise.exercise.id)
        .toList();

    return Scaffold(
      appBar: GlassAppBar(
        title: const AppLogo(),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Workout options',
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'finish',
                enabled: false,
                child: Text('Finish workout early'),
              ),
              PopupMenuItem(
                value: 'cancel',
                enabled: false,
                child: Text('Cancel workout'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Workout in progress'),
          WorkoutSetCard(
            key: ValueKey(workoutExercise.exercise.id),
            exerciseName: workoutExercise.exercise.name,
            setNumber: completedSets.length + 1,
            weight: 0.0,
            repetitions: workoutExercise.plannedRepetitions,
            numberOfExercises: workout.exercises.length,
            exerciseIndex: exerciseIndex,
            plannedSets: workoutExercise.plannedSets,
            plannedRepetitions: workoutExercise.plannedRepetitions,
            onRegister: (weight, repetitions) {
              final registeredSet = widget.workoutSessionController
                  .addSetToSession(
                    sessionId: widget.sessionId,
                    exerciseId: workoutExercise.exercise.id,
                    weight: weight,
                    repetitions: repetitions,
                  );
              if (registeredSet == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to register set.')),
                );
                return;
              }
              final isLastExercise =
                  exerciseIndex == workout.exercises.length - 1;
              final isLastSet =
                  completedSets.length + 1 >= workoutExercise.plannedSets;

              if (isLastExercise && isLastSet) {
                widget.workoutSessionController.completeSession(
                  widget.sessionId,
                );
              }

              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
