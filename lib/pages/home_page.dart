import 'package:flutter/material.dart';
import 'package:gym_tracker_app/dev/theme_preview_page.dart';
import '../widgets/workout_card.dart';
import '../controllers/workout_controller.dart';

class HomePage extends StatelessWidget {
  final WorkoutController controller;

  const HomePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final workouts = controller.getAllWorkouts();
    final workout = workouts.isEmpty ? null : workouts.last;

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
                          'Your workout for today is',
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
                child: workout == null
                    ? const Text('Create a workout in the Workouts tab.')
                    : WorkoutCard(
                        title: workout.name,
                        exercises: workout.exercises
                            .map((exercise) => exercise.name)
                            .toList(),
                        onStart: () {},
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
