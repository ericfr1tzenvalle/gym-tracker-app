import 'package:flutter/material.dart';
import 'package:gym_tracker_app/widgets/app_logo.dart';
import 'package:gym_tracker_app/widgets/create_workout_dialog.dart';
import '../controllers/workout_controller.dart';
import '../models/workouts.dart';
import '../widgets/glass_surface.dart';

class WorkoutDetails extends StatefulWidget {
  final Workout workout;
  final WorkoutController controller;
  const WorkoutDetails({
    super.key,
    required this.workout,
    required this.controller,
  });

  @override
  State<WorkoutDetails> createState() => _WorkoutDetailsState();
}

class _WorkoutDetailsState extends State<WorkoutDetails> {
  void _showActiveNotice() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Finish or cancel the active session before editing this workout.',
          ),
        ),
      );
  }

  Widget _buildOptions(Workout workout, bool canModify) {
    if (!canModify) {
      return IconButton(
        tooltip: 'Workout options',
        onPressed: _showActiveNotice,
        icon: const Icon(Icons.settings_outlined, color: Colors.white38),
      );
    }
    return PopupMenuButton<String>(
      tooltip: 'Workout options',
      icon: const Icon(Icons.settings_outlined),
      onSelected: (value) {
        if (!widget.controller.canModifyWorkout(workout.id)) {
          _showActiveNotice();
          return;
        }
        if (value == 'rename') _renameWorkout(workout);
        if (value == 'delete') {
          final deleted = widget.controller.deleteWorkout(workout.id);
          if (deleted) {
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not delete the workout. Try again.'),
              ),
            );
          }
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'rename', child: Text('Rename workout')),
        PopupMenuItem(value: 'delete', child: Text('Delete workout')),
      ],
    );
  }

  Future<void> _renameWorkout(Workout workout) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => CreateWorkoutDialog(
        title: 'Rename Workout',
        actionLabel: 'Save',
        initialName: workout.name,
        onCreate: (name) {
          final error = widget.controller.validateWorkoutName(
            name,
            ignoredWorkoutId: workout.id,
          );
          if (error != null) return error;
          return widget.controller.updateWorkoutName(workout.id, name)
              ? null
              : 'Could not rename the workout. Try again.';
        },
      ),
    );

    if (!mounted || updated != true) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final workout =
        widget.controller.getWorkoutById(widget.workout.id) ?? widget.workout;
    final canModify = widget.controller.canModifyWorkout(workout.id);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: const AppLogo(),
        actions: [_buildOptions(workout, canModify), const SizedBox(width: 8)],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FloatingActionButton.extended(
            onPressed: canModify ? () {} : _showActiveNotice,
            backgroundColor: canModify
                ? const Color(0xFFCA2123)
                : Theme.of(context).disabledColor.withValues(alpha: 0.12),
            foregroundColor: canModify
                ? Colors.white
                : Theme.of(context).disabledColor,
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Exercise',
              style: TextStyle(
                fontFamily: 'Montserrant',
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
      body: GlassBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: const TextStyle(
                    fontFamily: 'MatchaMint',
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.035),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 5,
                        color: canModify
                            ? Colors.white38
                            : const Color(0xFFB88787),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        canModify ? 'Inactive' : 'Active',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text("${workout.exercises.length} exercises"),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Exercises',
                        style: TextStyle(
                          fontFamily: 'MatchaMint',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('History'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: workout.exercises.length,
                    itemBuilder: (context, index) {
                      final exercises = workout.exercises[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassSurface(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              exercises.exercise.name,
                              style: const TextStyle(
                                fontFamily: 'MatchaMint',
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              '${exercises.plannedSets} sets - ${exercises.plannedRepetitions} reps',
                            ),
                            trailing: !canModify
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      widget.controller
                                          .removeExerciseFromWorkout(
                                            workout.id,
                                            exercises.exercise.id,
                                          );
                                      setState(() {});
                                    },
                                    tooltip: 'Remove exercise',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
