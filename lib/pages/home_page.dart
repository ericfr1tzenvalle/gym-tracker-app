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
                    child: _WeeklyStat(
                      icon: Icons.fitness_center_rounded,
                      label: 'Weight Lifted',
                      value: '${volume.toStringAsFixed(1)} kg',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _WeeklyStat(
                      icon: Icons.event_available_rounded,
                      label: 'Workouts Completed',
                      value: '${completed.length} / ${widget.weeklyGoal}',
                      progress: (completed.length / widget.weeklyGoal).clamp(
                        0.0,
                        1.0,
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

class _WeeklyStat extends StatelessWidget {
  const _WeeklyStat({
    required this.icon,
    required this.label,
    required this.value,
    this.progress,
  });

  final IconData icon;
  final String label;
  final String value;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return AspectRatio(
      aspectRatio: 1,
      child: GlassSurface(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: accent.withValues(alpha: .14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(icon, color: accent, size: 18),
                ),
              ),
              const Spacer(),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(label, style: theme.textTheme.labelMedium),
                ),
              ),
              const SizedBox(height: 8),
              if (progress case final target?)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: target),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    borderRadius: BorderRadius.circular(6),
                  ),
                )
              else
                const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
