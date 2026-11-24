import 'package:flutter/material.dart';
import '../controllers/workout_session_controller.dart';
import '../models/workout_session_status.dart';

class EvolutionPage extends StatelessWidget {
  const EvolutionPage({
    super.key,
    required this.controller,
    this.workoutId,
    this.workoutName,
  });
  final WorkoutSessionController controller;
  final String? workoutId;
  final String? workoutName;

  @override
  Widget build(BuildContext context) {
    final sessions =
        controller
            .getAllSessions()
            .where(
              (session) =>
                  session.status == WorkoutSessionStatus.completed &&
                  (workoutId == null || session.workoutId == workoutId),
            )
            .toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(workoutName == null ? 'History' : '$workoutName History'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Sessions'),
              Tab(text: 'Exercises'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            sessions.isEmpty
                ? const Center(child: Text('No completed workouts.'))
                : ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return ListTile(
                        title: Text(session.workoutName),
                        subtitle: Text(
                          '${session.startedAt.day}/${session.startedAt.month}/${session.startedAt.year} • ${session.sets.length} sets',
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => Scaffold(
                              appBar: AppBar(title: Text(session.workoutName)),
                              body: ListView(
                                children: [
                                  for (final set in session.sets)
                                    ListTile(
                                      title: Text(set.exerciseName),
                                      subtitle: Text(
                                        '${set.weight} kg × ${set.repetitions} reps',
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            Builder(
              builder: (context) {
                final names = {
                  for (final session in sessions)
                    for (final set in session.sets) set.exerciseName,
                }.toList()..sort();
                return names.isEmpty
                    ? const Center(child: Text('No exercises logged.'))
                    : ListView(
                        children: [
                          for (final name in names)
                            ExpansionTile(
                              title: Text(name),
                              children: [
                                for (final session in sessions)
                                  for (final set in session.sets.where(
                                    (set) => set.exerciseName == name,
                                  ))
                                    ListTile(
                                      title: Text(
                                        '${set.weight} kg × ${set.repetitions} reps',
                                      ),
                                      subtitle: Text(
                                        '${session.startedAt.day}/${session.startedAt.month}/${session.startedAt.year} • ${session.workoutName}',
                                      ),
                                    ),
                              ],
                            ),
                        ],
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
