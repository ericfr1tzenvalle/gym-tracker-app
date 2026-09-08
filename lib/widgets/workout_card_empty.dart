import 'package:flutter/material.dart';

class WorkoutCardEmpty extends StatelessWidget {
  final VoidCallback onTap;

  const WorkoutCardEmpty({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Text('+', style: TextStyle(fontSize: 16, fontFamily: 'MatchaMint'),),
      label: const Text('New Workout'),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(fontSize: 12, fontFamily: 'MatchaMint'),
      ),
    );
  }
}
