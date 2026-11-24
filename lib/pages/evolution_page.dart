import 'package:flutter/material.dart';
import '../controllers/workout_session_controller.dart';
import '../models/workout_session_status.dart';
import '../widgets/glass_surface.dart';

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
    final title = workoutName ?? 'History';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: workoutId != null || ModalRoute.of(context)?.canPop == true
            ? GlassAppBar(title: const Text('History'))
            : null,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Text(
                title,
                style: const TextStyle(fontFamily: 'MatchaMint', fontSize: 22),
              ),
            ),
            const TabBar(
              tabs: [
                Tab(text: 'Sessions'),
                Tab(text: 'Exercises'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  sessions.isEmpty
                      ? const Center(child: Text('No completed workouts.'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                          itemCount: sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            return _HistoryCard(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.event_available_outlined,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                title: _HistoryTitle(session.workoutName),
                                subtitle: Text(
                                  '${session.startedAt.day}/${session.startedAt.month}/${session.startedAt.year} • ${session.sets.length} sets',
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => Scaffold(
                                      appBar: GlassAppBar(
                                        title: _HistoryTitle(
                                          session.workoutName,
                                        ),
                                      ),
                                      body: ListView(
                                        padding: const EdgeInsets.all(16),
                                        children: [
                                          for (final set in session.sets)
                                            _HistoryCard(
                                              child: ListTile(
                                                leading: const Icon(
                                                  Icons.fitness_center,
                                                ),
                                                title: _HistoryTitle(
                                                  set.exerciseName,
                                                ),
                                                subtitle: Text(
                                                  '${set.weight} kg × ${set.repetitions} reps',
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
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
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                110,
                              ),
                              children: [
                                for (final name in names)
                                  _HistoryCard(
                                    child: ExpansionTile(
                                      shape: const Border(),
                                      collapsedShape: const Border(),
                                      leading: const Icon(Icons.fitness_center),
                                      title: _HistoryTitle(name),
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
                                  ),
                              ],
                            );
                    },
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: GlassSurface(radius: 16, child: child),
  );
}

class _HistoryTitle extends StatelessWidget {
  const _HistoryTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(fontFamily: 'MatchaMint', fontSize: 13),
  );
}
