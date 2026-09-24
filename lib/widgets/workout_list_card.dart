import 'package:flutter/material.dart';
import 'glass_surface.dart';

class WorkoutListCard extends StatelessWidget {
  final String title;
  final int exerciseCount;
  final VoidCallback onTap;
  const WorkoutListCard({
    super.key,
    required this.title,
    required this.exerciseCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: TextStyle(fontFamily: 'MatchaMint', fontSize: 13),
        ),
        onTap: onTap,
        trailing: const Icon(Icons.chevron_right),
        subtitle: Text(
          exerciseCount == 1 ? '1 exercise' : '$exerciseCount exercises',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
