import 'package:flutter/material.dart';

import '../controllers/workout_session_controller.dart';
import '../widgets/app_logo.dart';
import '../widgets/workout_session_actions.dart';
import '../widgets/workout_session_summary.dart';
import '../widgets/workout_set_card.dart';

class WorkoutSessionPage extends StatefulWidget {
  final WorkoutSessionController workoutSessionController;
  final String sessionId;

  const WorkoutSessionPage({
    super.key,
    required this.workoutSessionController,
    required this.sessionId,
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  void _showError(String message) {
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _endSession({required bool cancel}) {
    final controller = widget.workoutSessionController;
    final updated = cancel
        ? controller.cancelSession(widget.sessionId)
        : controller.completeSession(widget.sessionId);
    if (!updated) _showError('Could not update this session.');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.workoutSessionController.getSessionProgress(
      widget.sessionId,
    );
    final exercise = progress?.currentExercise;

    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(),
        actions: [
          if (progress != null && progress.session.isActive)
            WorkoutSessionActions(
              canFinish: progress.totalCompletedSets > 0,
              onFinish: () => _endSession(cancel: false),
              onCancel: () => _endSession(cancel: true),
            ),
        ],
      ),
      body: progress == null
          ? const Center(child: Text('Session not found'))
          : !progress.session.isActive
          ? WorkoutSessionSummary(
              progress: progress,
              onDone: () => Navigator.of(context).maybePop(),
            )
          : exercise == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No exercises available. Use the workout options to end this session.',
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(progress.workout!.name),
                const Text('Workout in progress'),
                const SizedBox(height: 16),
                WorkoutSetCard(
                  key: ValueKey(exercise.exercise.id),
                  exerciseName: exercise.exercise.name,
                  setNumber: progress.currentExerciseCompletedSets + 1,
                  weight: progress.suggestedSet?.weight ?? 0,
                  repetitions:
                      progress.suggestedSet?.repetitions ??
                      exercise.plannedRepetitions,
                  numberOfExercises: progress.workout!.exercises.length,
                  exerciseIndex: progress.exerciseIndex,
                  plannedSets: exercise.plannedSets,
                  plannedRepetitions: exercise.plannedRepetitions,
                  onRegister: (weight, repetitions) {
                    final registered = widget.workoutSessionController
                        .addSetToSession(
                          sessionId: widget.sessionId,
                          exerciseId: exercise.exercise.id,
                          weight: weight,
                          repetitions: repetitions,
                        );
                    if (registered == null) {
                      _showError('Failed to register set.');
                    }
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                const Text('You can return home and resume this session.'),
              ],
            ),
    );
  }
}
