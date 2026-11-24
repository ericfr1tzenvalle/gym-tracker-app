import 'workout_details.dart';
import '../controllers/exercise_controller.dart';
import 'package:flutter/material.dart';
import '../models/workout_session_status.dart';
import '../widgets/glass_surface.dart';

import '../widgets/workout_card.dart';
import '../widgets/workout_card_empty.dart';
import '../widgets/create_workout_dialog.dart';
import '../controllers/workout_controller.dart';
import '../controllers/workout_session_controller.dart';
import 'workout_session_page.dart';

class HomePage extends StatefulWidget {
  final WorkoutController controller;
  final ExerciseController exerciseController;
  final WorkoutSessionController workoutSessionController;

  final String username;
  final int weeklyGoal;

  const HomePage({
    super.key,
    required this.username,
    required this.weeklyGoal,
    required this.controller,
    required this.exerciseController,
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
                          'Hi, ${widget.username}!',
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
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: workouts.isEmpty
                    ? WorkoutCardEmpty(onTap: _createWorkout)
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position:
                                Tween(
                                  begin: const Offset(.06, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                            child: child,
                          ),
                        ),
                        child: WorkoutCard(
                          key: ValueKey(workout?.id),
                          title: workout?.name ?? 'Workout unavailable',
                          exercises:
                              workout?.exercises
                                  .map((item) => item.exercise.name)
                                  .toList() ??
                              const [],
                          actionLabel: activeSession != null
                              ? 'Resume Workout'
                              : 'Start Workout',
                          onSwap: activeSession != null || alternatives.isEmpty
                              ? null
                              : () async {
                                  final id = await showModalBottomSheet<String>(
                                    context: context,
                                    useSafeArea: true,
                                    showDragHandle: true,
                                    sheetAnimationStyle: const AnimationStyle(
                                      duration: Duration(milliseconds: 360),
                                      reverseDuration: Duration(
                                        milliseconds: 240,
                                      ),
                                    ),
                                    builder: (context) => ListView(
                                      shrinkWrap: true,
                                      children: [
                                        const ListTile(
                                          leading: Icon(Icons.swap_horiz),
                                          title: Text('Swap Workout'),
                                        ),
                                        for (final item in alternatives)
                                          ListTile(
                                            leading: const CircleAvatar(
                                              child: Icon(
                                                Icons.fitness_center,
                                                size: 18,
                                              ),
                                            ),
                                            trailing: const Icon(
                                              Icons.arrow_forward_rounded,
                                            ),
                                            title: Text(item.name),
                                            subtitle: Text(
                                              '${item.exercises.length} exercises',
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
                          onDetails: workout == null
                              ? null
                              : () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => WorkoutDetails(
                                        workout: workout,
                                        controller: widget.controller,
                                        exerciseController:
                                            widget.exerciseController,
                                        sessionController:
                                            widget.workoutSessionController,
                                      ),
                                    ),
                                  );
                                  if (mounted) setState(() {});
                                },
                          onStart: () => _openSession(workout?.id),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This Week',
                style: TextStyle(fontFamily: 'MatchaMint'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _WeeklyTile(
                      label: 'Workouts Completed',
                      caption: 'Weekly goal: ${widget.weeklyGoal}',
                      icon: Icons.event_available_outlined,
                      metric: SizedBox.square(
                        dimension: 76,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(
                                end: (completed.length / widget.weeklyGoal)
                                    .clamp(0.0, 1.0),
                              ),
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) =>
                                  CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 4,
                                    strokeCap: StrokeCap.round,
                                    backgroundColor: Colors.white12,
                                  ),
                            ),
                            Center(
                              child: Text(
                                '${completed.length}',
                                style: textTheme.headlineMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WeeklyTile(
                      label: 'Weight Lifted',
                      caption: 'Total training volume',
                      icon: Icons.fitness_center_rounded,
                      metric: Text.rich(
                        TextSpan(
                          text: volume.toStringAsFixed(
                            volume == volume.roundToDouble() ? 0 : 1,
                          ),
                          style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          children: [
                            TextSpan(
                              text: ' kg',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyTile extends StatelessWidget {
  const _WeeklyTile({
    required this.label,
    required this.caption,
    required this.icon,
    required this.metric,
  });

  final String label;
  final String caption;
  final IconData icon;
  final Widget metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 1,
      child: GlassSurface(
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: FittedBox(fit: BoxFit.scaleDown, child: metric),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        icon,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    caption,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
