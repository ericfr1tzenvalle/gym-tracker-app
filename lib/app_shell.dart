import 'package:flutter/material.dart';
import 'package:gym_tracker_app/pages/evolution_page.dart';
import 'package:gym_tracker_app/pages/home_page.dart';
import 'package:gym_tracker_app/pages/profile_page.dart';
import 'package:gym_tracker_app/pages/workouts_page.dart';
import 'widgets/app_logo.dart';
import 'controllers/workout_controller.dart';
import 'repositories/workout_repository.dart';
import 'repositories/session_repository.dart';
import 'controllers/workout_session_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _workoutRepository = WorkoutRepository();
  final _sessionRepository = SessionRepository();
  late final _workoutController = WorkoutController(
    _workoutRepository,
    _sessionRepository,
  );

  late final _workoutSessionController = WorkoutSessionController(
    _sessionRepository,
    _workoutRepository,
  );

  List<Widget> get _pages => [
    HomePage(
      controller: _workoutController,
      workoutSessionController: _workoutSessionController,
    ),
    WorkoutsPage(controller: _workoutController),
    const EvolutionPage(),
    const ProfilePage(),
  ];
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        centerTitle: true,
        title: const AppLogo(),
        backgroundColor: Colors.transparent,
      ),
      body: _pages[_selectedIndex],

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
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
  }
}
