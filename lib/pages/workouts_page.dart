import 'package:flutter/material.dart';
import 'package:gym_tracker_app/widgets/create_workout_dialog.dart';
import 'package:gym_tracker_app/widgets/workout_card_empty.dart';
import '../widgets/workout_list_card.dart';
import '../controllers/workout_controller.dart';

class WorkoutsPage extends StatefulWidget {
  final WorkoutController controller;
  const WorkoutsPage({super.key, required this.controller});

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
              const Text(
                'Your workouts',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'MatchaMint',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: workouts.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == workouts.length) {
                      return WorkoutCardEmpty(onTap: _createWorkout);
                    }
                    final treino = workouts[index];

                    return WorkoutListCard(
                      title: treino.name,
                      onTap: () {

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
