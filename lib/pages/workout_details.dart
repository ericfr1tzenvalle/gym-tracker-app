import 'package:flutter/material.dart';
import 'package:gym_tracker_app/widgets/app_logo.dart';
import 'package:gym_tracker_app/widgets/create_workout_dialog.dart';
import '../controllers/workout_controller.dart';
import '../models/workouts.dart';

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
    return Scaffold(
      appBar: AppBar(title: const AppLogo(), centerTitle: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: const Color(0xFFCA2123),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'Exercise',
              style: TextStyle(fontFamily: 'MatchaMint', fontSize: 12),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    workout.name,
                    style: const TextStyle(
                      fontFamily: 'MatchaMint',
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Workout options',
                  icon: const Icon(Icons.settings_outlined),
                  onSelected: (value) {
                    if (value == 'rename') {
                      _renameWorkout(workout);
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value: 'rename',
                        child: Text('Rename workout'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete workout'),
                      ),
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("${workout.exercises.length} exercises"),
            const SizedBox(height: 22),
            Text(
              "Exercises",
              style: TextStyle(
                fontFamily: 'MatchaMint',
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 96),
                itemCount: workout.exercises.length,
                itemBuilder: (context, index) {
                  final exercises = workout.exercises[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
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
                      trailing: IconButton(
                        onPressed: () {
                          widget.controller.removeExerciseFromWorkout(
                            workout.id,
                            exercises.exercise.id,
                          );
                          setState(() {});
                        },
                        tooltip: 'Remove exercise',
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
