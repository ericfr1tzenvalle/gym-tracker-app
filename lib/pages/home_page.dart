import 'package:flutter/material.dart';
import '../models/workout_session_status.dart';

import '../widgets/workout_card.dart';
import '../widgets/workout_card_empty.dart';
import '../widgets/create_workout_dialog.dart';
import '../controllers/workout_controller.dart';
import '../controllers/workout_session_controller.dart';
import 'workout_session_page.dart';

class HomePage extends StatefulWidget {
  final WorkoutController controller;
  final WorkoutSessionController workoutSessionController;

  final String username;
  final int weeklyGoal;

  const HomePage({
    super.key,
    required this.username,
    required this.weeklyGoal,
    required this.controller,
    required this.workoutSessionController,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedWorkoutId;
  bool _openingSession = false;
  bool _creationDialogOpen = false;

  Future<void> _createWorkout() async {
    if (_creationDialogOpen) return;
    _creationDialogOpen = true;
    try {
      final created = await showDialog<bool>(
        context: context,
        builder: (context) => CreateWorkoutDialog(
          onCreate: (name) {
            if (!mounted) return 'This page is no longer available.';
            final error = widget.controller.validateWorkoutName(name);
            if (error != null) return error;
            return widget.controller.createWorkout(name)
                ? null
                : 'Could not create the workout. Try again.';
          },
        ),
      );
      if (!mounted || created != true) return;
      setState(() {});
    } finally {
      _creationDialogOpen = false;
    }
  }

  Future<void> _openSession(String? workoutId) async {
    if (_openingSession) return;
    _openingSession = true;
    try {
      final controller = widget.workoutSessionController;
      final activeSession = controller.getActiveSession();
      if (activeSession == null && workoutId == null) return;
      final session =
          activeSession ?? controller.startOrResumeSession(workoutId!);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => WorkoutSessionPage(
            workoutSessionController: controller,
            sessionId: session.id,
          ),
        ),
      );
      if (mounted) {
        setState(() {
          if (controller.getActiveSession() == null) _selectedWorkoutId = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            'Unable to start the session. Make sure the workout exists and has exercises.',
          ),
        ),
      );
    } finally {
      _openingSession = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final workouts = widget.controller.getAllWorkouts();
    final nextWorkout = widget.controller.getNextWorkout();
    final activeSession = widget.workoutSessionController.getActiveSession();
    final workout = activeSession != null
        ? widget.controller.getWorkoutById(activeSession.workoutId)
        : (_selectedWorkoutId == null
                  ? null
                  : widget.controller.getWorkoutById(_selectedWorkoutId!)) ??
              (nextWorkout == null ? null : workouts[nextWorkout]);
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final nextMonday = DateTime(monday.year, monday.month, monday.day + 7);
    final completed = widget.workoutSessionController.getAllSessions().where((
      session,
    ) {
      final date = session.completedAt?.toLocal();
      return session.status == WorkoutSessionStatus.completed &&
          date != null &&
          !date.isBefore(monday) &&
          date.isBefore(nextMonday);
    }).toList();
    final volume = completed
        .expand((session) => session.sets)
        .fold<double>(0, (sum, set) => sum + set.weight * set.repetitions);
    final alternatives = workouts
        .where((item) => item.id != workout?.id)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${widget.username}!',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'MatchaMint',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workouts.isEmpty
                              ? 'Create your first workout'
                              : activeSession != null
                              ? 'Continue your active workout'
                              : 'Your workout for today is',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: activeSession != null || alternatives.isEmpty
                        ? null
                        : () async {
                            final id = await showModalBottomSheet<String>(
                              context: context,
                              useSafeArea: true,
                              builder: (context) => ListView(
                                shrinkWrap: true,
                                children: [
                                  const ListTile(
                                    title: Text('Trocar treino de hoje'),
                                  ),
                                  for (final item in alternatives)
                                    ListTile(
                                      title: Text(item.name),
                                      subtitle: Text(
                                        '${item.exercises.length} exercícios',
                                      ),
                                      onTap: () =>
                                          Navigator.pop(context, item.id),
                                    ),
                                ],
                              ),
                            );
                            if (mounted && id != null) {
                              setState(() => _selectedWorkoutId = id);
                            }
                          },
                    tooltip: 'Trocar treino',
                    icon: const Icon(Icons.swap_horiz),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: workouts.isEmpty
                    ? WorkoutCardEmpty(onTap: _createWorkout)
                    : WorkoutCard(
                        title: workout?.name ?? 'Workout unavailable',
                        exercises:
                            workout?.exercises
                                .map((item) => item.exercise.name)
                                .toList() ??
                            const [],
                        actionLabel: activeSession != null
                            ? 'Resume Workout'
                            : 'Start Workout',
                        onStart: () => _openSession(workout?.id),
                      ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Peso levantado nesta semana'),
                subtitle: Text('${volume.toStringAsFixed(1)} kg'),
              ),
              ListTile(
                title: const Text('Treinos concluídos nesta semana'),
                subtitle: Text('${completed.length} de ${widget.weeklyGoal}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
