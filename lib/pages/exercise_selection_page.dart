import 'package:flutter/material.dart';
import 'package:gym_tracker_app/controllers/exercise_controller.dart';
import 'package:gym_tracker_app/controllers/workout_controller.dart';
import 'package:gym_tracker_app/models/muscle_groups.dart';
import 'package:gym_tracker_app/widgets/app_logo.dart';
import 'package:gym_tracker_app/widgets/glass_surface.dart';

class ExerciseSelectionPage extends StatefulWidget {
  const ExerciseSelectionPage({
    super.key,
    required this.workoutId,
    required this.controller,
    required this.exerciseController,
  });

  final String workoutId;
  final WorkoutController controller;
  final ExerciseController exerciseController;

  @override
  State<ExerciseSelectionPage> createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<ExerciseSelectionPage> {
  MuscleGroup? _selectedMuscleGroup;

  @override
  Widget build(BuildContext context) {
    final allExercises = widget.exerciseController.getAllExercises();
    final filteredExercises = _selectedMuscleGroup == null
        ? allExercises
        : allExercises
            .where((exercise) => exercise.muscleGroup == _selectedMuscleGroup)
            .toList();

    return Scaffold(
      appBar: GlassAppBar(title: const AppLogo()),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(padding: EdgeInsets.all(16), child: SearchBar()),
            SizedBox(height: 12),
            SizedBox(
              height: 30,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 22),
                itemBuilder: ((context, index) {
                  if (index == 0) {
                    return ChoiceChip(
                      label: const Text('ALL'),
                      selected: _selectedMuscleGroup == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedMuscleGroup = null;
                        });
                      },
                      labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Color(0xFFCA2123),
                      ),
                      side: BorderSide(color: Colors.black),
                      showCheckmark: false,
                      selectedColor: Colors.black,
                    );
                  }
                  final muscleGroup = MuscleGroup.values[index - 1];
                  return ChoiceChip(
                    label: Text(muscleGroup.name.toUpperCase()),
                    selected: _selectedMuscleGroup == muscleGroup,
                    onSelected: (bool isSelected) {
                      setState(() {
                        _selectedMuscleGroup = isSelected ? muscleGroup : null;
                      });
                    },
                    labelStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Color(0xFFCA2123),
                    ),
                    side: BorderSide(color: Colors.black),
                    showCheckmark: false,
                    selectedColor: Colors.black,
                  );
                }),
                separatorBuilder: ((context, index) {
                  return SizedBox(width: 8);
                }),
                itemCount: MuscleGroup.values.length + 1,
                scrollDirection: Axis.horizontal,
              ),
            ),
            SizedBox(height: 22),
            Divider(
              height: 4,
              thickness: 0.2,
              indent: 16,
              endIndent: 16,
              color: Colors.grey,
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final exercise = filteredExercises[index];
                  return ListTile(title: Text(exercise.name));
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemCount: filteredExercises.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
