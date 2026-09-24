import 'package:flutter/material.dart';
import 'glass_surface.dart';

class WorkoutCardEmpty extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const WorkoutCardEmpty({
    super.key,
    required this.onTap,
    this.label = 'New Workout',
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No workouts yet',
                    style: TextStyle(fontFamily: 'MatchaMint', fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to create your first workout.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontFamily: 'MatchaMint',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
