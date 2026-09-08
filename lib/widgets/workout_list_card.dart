import 'package:flutter/material.dart';

class WorkoutListCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const WorkoutListCard({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: TextStyle(fontFamily: 'MatchaMint', fontSize: 13),
        ),
        onTap: onTap,
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}
