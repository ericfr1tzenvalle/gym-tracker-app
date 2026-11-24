import 'package:flutter/material.dart';

import '../widgets/glass_surface.dart';

import '../controllers/workout_session_controller.dart';
import '../widgets/app_logo.dart';
import '../widgets/workout_session_actions.dart';
import '../models/workout_set.dart';
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

  Future<void> _editSet(WorkoutSet set) async {
    final weight = TextEditingController(text: set.weight.toString());
    final reps = TextEditingController(text: set.repetitions.toString());
    final edited = await showDialog<(double, int)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar série • ${set.exerciseName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Carga (kg), mínimo 0',
              ),
            ),
            TextField(
              controller: reps,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Repetições, inteiro positivo',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final w = double.tryParse(weight.text.replaceAll(',', '.'));
              final r = int.tryParse(reps.text);
              if (w == null || !w.isFinite || w < 0 || r == null || r <= 0) {
                return;
              }
              Navigator.pop(context, (w, r));
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    weight.dispose();
    reps.dispose();
    if (edited == null || !mounted) return;
    widget.workoutSessionController.updateSet(
      sessionId: widget.sessionId,
      setId: set.id,
      weight: edited.$1,
      repetitions: edited.$2,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.workoutSessionController.getSessionProgress(
      widget.sessionId,
    );
    final exercise = progress?.currentExercise;

    return Scaffold(
      appBar: GlassAppBar(
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
      bottomNavigationBar: progress != null && progress.session.isActive
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: progress.totalCompletedSets == 0
                      ? null
                      : () => _endSession(cancel: false),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Finalizar treino'),
                ),
              ),
            )
          : null,
      body: progress == null
          ? const Center(child: Text('Session not found'))
          : !progress.session.isActive
          ? WorkoutSessionSummary(
              progress: progress,
              onDone: () => Navigator.of(context).maybePop(),
            )
          : exercise == null
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                const Text(
                  'Todas as séries planejadas foram registradas. Você pode corrigir ou finalizar.',
                ),
                const SizedBox(height: 16),
                for (final set in progress.session.sets)
                  ListTile(
                    title: Text(
                      '${set.exerciseName}: ${set.weight} kg × ${set.repetitions} reps',
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          onPressed: () => _editSet(set),
                          icon: const Icon(Icons.edit),
                          tooltip: 'Editar série',
                        ),
                        IconButton(
                          onPressed: () {
                            widget.workoutSessionController
                                .removeSetFromSession(
                                  sessionId: widget.sessionId,
                                  setId: set.id,
                                );
                            setState(() {});
                          },
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Excluir série',
                        ),
                      ],
                    ),
                  ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                WorkoutSetCard(
                  key: ValueKey(
                    '${widget.sessionId}:${exercise.exercise.id}:${progress.currentExerciseCompletedSets}',
                  ),
                  exerciseName: exercise.exercise.name,
                  setNumber: progress.currentExerciseCompletedSets + 1,
                  weight: progress.suggestedSet?.weight,
                  repetitions: progress.suggestedSet?.repetitions,
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
                    return registered != null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('Séries registradas'),
                for (final set in progress.session.sets)
                  ListTile(
                    title: Text(
                      '${set.exerciseName}: ${set.weight} kg × ${set.repetitions} reps',
                    ),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          onPressed: () => _editSet(set),
                          icon: const Icon(Icons.edit),
                          tooltip: 'Editar série',
                        ),
                        IconButton(
                          onPressed: () {
                            widget.workoutSessionController
                                .removeSetFromSession(
                                  sessionId: widget.sessionId,
                                  setId: set.id,
                                );
                            setState(() {});
                          },
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Excluir série',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
