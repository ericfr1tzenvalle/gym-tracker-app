import 'package:flutter/material.dart';

import '../models/workout_session_progress.dart';
import '../models/workout_session_status.dart';

class WorkoutSessionSummary extends StatelessWidget {
  final WorkoutSessionProgress progress;
  final VoidCallback onDone;

  const WorkoutSessionSummary({
    super.key,
    required this.progress,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cancelled = progress.session.status == WorkoutSessionStatus.cancelled;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(
          cancelled ? Icons.cancel_outlined : Icons.check_circle_outline,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          cancelled ? 'Workout cancelled' : 'Workout completed!',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        if (progress.workout != null) ...[
          const SizedBox(height: 8),
          Text(progress.workout!.name, textAlign: TextAlign.center),
        ],
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${progress.totalCompletedSets} ${progress.totalCompletedSets == 1 ? 'set' : 'sets'} registered',
                ),
                const SizedBox(height: 8),
                Text(
                  '${progress.completedExercises} ${progress.completedExercises == 1 ? 'exercise' : 'exercises'} completed',
                ),
                const SizedBox(height: 8),
                Text(
                  '${progress.totalVolume.toStringAsFixed(1)} kg total volume',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: onDone, child: const Text('Back to home')),
      ],
    );
  }
}
