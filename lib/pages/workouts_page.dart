import 'package:flutter/material.dart';
import 'package:gym_tracker_app/widgets/create_workout_dialog.dart';
import '../widgets/workout_list_card.dart';
import '../widgets/workout_card_empty.dart';
import '../controllers/workout_controller.dart';
import 'workout_details.dart';
import '../controllers/exercise_controller.dart';

class WorkoutsPage extends StatefulWidget {
  final WorkoutController controller;
  final ExerciseController exerciseController;
  const WorkoutsPage({
    super.key,
    required this.controller,
    required this.exerciseController,
  });

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
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

  @override
  Widget build(BuildContext context) {
    final workouts = widget.controller.getAllWorkouts();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Your workouts',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'MatchaMint',
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _createWorkout,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFCA2123),
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(
                        fontFamily: 'MatchaMint',
                        fontSize: 12,
                      ),
                      side: const BorderSide(color: Color(0xFFCA2123)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: workouts.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.only(bottom: 112),
                        children: [WorkoutCardEmpty(onTap: _createWorkout)],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 112),
                        itemCount: workouts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final treino = workouts[index];

                          return WorkoutListCard(
                            title: treino.name,
                            exerciseCount: treino.exercises.length,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return WorkoutDetails(
                                      workout: treino,
                                      controller: widget.controller,
                                      exerciseController:
                                          widget.exerciseController,
                                    );
                                  },
                                ),
                              );
                              if (!context.mounted) return;
                              setState(() {});
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
