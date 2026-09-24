import 'package:flutter/material.dart';
import 'package:gym_tracker_app/dev/theme_preview_page.dart';

import '../widgets/workout_card.dart';
import '../widgets/workout_card_empty.dart';
import '../widgets/create_workout_dialog.dart';
import '../controllers/workout_controller.dart';
import '../controllers/workout_session_controller.dart';
import 'workout_session_page.dart';

class HomePage extends StatefulWidget {
  final WorkoutController controller;
  final WorkoutSessionController workoutSessionController;

  const HomePage({
    super.key,
    required this.controller,
    required this.workoutSessionController,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      if (mounted) setState(() {});
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
        : nextWorkout == null
        ? null
        : workouts[nextWorkout];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
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
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ThemePreviewPage(),
                        ),
                      );
                    },
                    tooltip: 'See theme preview',
                    icon: const Icon(Icons.info_outline),
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
            ],
          ),
        ),
      ),
    );
  }
}
