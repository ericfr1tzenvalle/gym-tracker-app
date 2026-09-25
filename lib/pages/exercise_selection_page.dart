import 'package:flutter/material.dart';
import 'package:gym_tracker_app/controllers/exercise_controller.dart';
import 'package:gym_tracker_app/controllers/workout_controller.dart';
import 'package:gym_tracker_app/models/muscle_groups.dart';
import 'package:gym_tracker_app/widgets/app_logo.dart';
import 'package:gym_tracker_app/widgets/glass_surface.dart';
import 'package:gym_tracker_app/models/exercises.dart';

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
  int? _selectedMuscleGroupIndex = 0;
  late List<Exercise> _filteredExercises = widget.exerciseController
      .getAllExercises();

  @override
  Widget build(BuildContext context) {
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
                      selected: _selectedMuscleGroupIndex == null,
                      onSelected: (_) {
                        setState(() {
                          _selectedMuscleGroupIndex = null;
                          _filteredExercises = widget.exerciseController
                              .getAllExercises();
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
                  final muscleGroupName = getNameOfMuscleGroups()[index - 1];
                  return ChoiceChip(
                    label: Text(muscleGroupName),
                    selected: _selectedMuscleGroupIndex == index,
                    onSelected: (bool isSelected) {
                      setState(() {
                        _selectedMuscleGroupIndex = isSelected ? index : null;
                        _filteredExercises = widget.exerciseController
                            .getAllExercises();
                        _filteredExercises = _filteredExercises
                            .where(
                              (exercise) =>
                                  exercise.muscleGroup.name.toUpperCase() ==
                                  muscleGroupName,
                            )
                            .toList();
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
                itemCount: getAllMuscleGroups() + 1,
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
                  final exercise = _filteredExercises[index];
                  return ListTile(title: Text(exercise.name));
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemCount: _filteredExercises.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
