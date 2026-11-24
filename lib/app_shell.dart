import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_tracker_app/controllers/exercise_controller.dart';
import 'package:gym_tracker_app/pages/evolution_page.dart';
import 'package:gym_tracker_app/pages/home_page.dart';
import 'package:gym_tracker_app/pages/workouts_page.dart';
import 'package:gym_tracker_app/repositories/exercise_repository.dart';
import 'widgets/app_logo.dart';
import 'widgets/glass_surface.dart';
import 'controllers/workout_controller.dart';
import 'repositories/workout_repository.dart';
import 'repositories/account_database.dart';
import 'repositories/session_repository.dart';
import 'controllers/workout_session_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.uid});
  final String uid;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AccountDatabase? _store;
  late final _exerciseRepository = ExerciseRepository();
  late final _exerciseController = ExerciseController(_exerciseRepository);
  WorkoutController? _workoutController;
  WorkoutSessionController? _workoutSessionController;
  late final Future<void> _ready = _initialize();

  Future<void> _initialize() async {
    final store = await AccountDatabase.open(widget.uid);
    final workouts = WorkoutRepository(store);
    final sessions = SessionRepository(store);
    await workouts.hydrate();
    await sessions.hydrate();
    if (!mounted) {
      await store.flush();
      return;
    }
    _store = store;
    _workoutController = WorkoutController(workouts, sessions);
    _workoutSessionController = WorkoutSessionController(sessions, workouts);
  }

  @override
  void dispose() {
    final store = _store;
    if (store != null) store.flush();
    super.dispose();
  }

  List<Widget> get _pages => [
    HomePage(
      controller: _workoutController!,
      workoutSessionController: _workoutSessionController!,
    ),
    WorkoutsPage(
      controller: _workoutController!,
      exerciseController: _exerciseController,
    ),
    EvolutionPage(controller: _workoutSessionController!),
    Center(
      child: FilledButton.icon(
        onPressed: () => FirebaseAuth.instance.signOut(),
        icon: const Icon(Icons.logout),
        label: const Text("Sair"),
      ),
    ),
  ];
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Erro ao abrir dados locais: ${snapshot.error}'),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          extendBody: true,
          appBar: GlassAppBar(centerTitle: true, title: const AppLogo()),
          body: _pages[_selectedIndex],

          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 18),
              child: GlassSurface(
                radius: 30,
                child: NavigationBar(
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  selectedIndex: _selectedIndex,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Home',
                    ),

                    NavigationDestination(
                      icon: Icon(Icons.fitness_center_outlined),
                      selectedIcon: Icon(Icons.fitness_center),
                      label: 'Workouts',
                    ),

                    NavigationDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      selectedIcon: Icon(Icons.bar_chart),
                      label: 'Evolution',
                    ),

                    NavigationDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
