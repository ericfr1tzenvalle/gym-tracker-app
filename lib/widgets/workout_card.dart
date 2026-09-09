import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final String title;
  final List<String> exercises;
  final VoidCallback onStart;
  final String actionLabel;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.exercises,
    required this.onStart,
    this.actionLabel = 'Start Workout',
  });

  @override
  Widget build(BuildContext context) {
    final preview = exercises.take(3).join(', ');
    final remaining = exercises.length - 3;
    var subtitle = preview;

    if (remaining > 0) {
      var word = 'exercícios';

      if (remaining == 1) {
        word = 'exercício';
      }

      subtitle = '$preview + $remaining $word';
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 4, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'MatchaMint',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Swap Workout',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (exercises.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'Montserrat',
                        color: Color.fromARGB(255, 219, 216, 216),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStart,
                      child: Text(actionLabel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
