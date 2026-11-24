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
                  return ListTile(
                    title: Text(exercise.name),
                    onTap: () async {
                      final sets = TextEditingController(text: '3');
                      final minReps = TextEditingController(text: '8');
                      final reps = TextEditingController(text: '12');
                      final result = await showDialog<(int, int, int)>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(exercise.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Sugestão: 3 séries de 8–12 repetições',
                              ),
                              TextField(
                                controller: sets,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Séries',
                                ),
                              ),
                              TextField(
                                controller: minReps,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Repetições mínimas',
                                ),
                              ),
                              TextField(
                                controller: reps,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Repetições máximas',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () {
                                final count = int.tryParse(sets.text);
                                final minimum = int.tryParse(minReps.text);
                                final repetitions = int.tryParse(reps.text);
                                if (count == null ||
                                    count < 1 ||
                                    minimum == null ||
                                    minimum < 1 ||
                                    repetitions == null ||
                                    repetitions < minimum) {
                                  return;
                                }
                                Navigator.pop(dialogContext, (
                                  count,
                                  minimum,
                                  repetitions,
                                ));
                              },
                              child: const Text('Adicionar'),
                            ),
                          ],
                        ),
                      );
                      sets.dispose();
                      minReps.dispose();
                      reps.dispose();
                      if (result == null || !context.mounted) return;
                      final added = widget.controller.addExerciseToWorkout(
                        widget.workoutId,
                        exercise,
                        plannedSets: result.$1,
                        plannedMinRepetitions: result.$2,
                        plannedRepetitions: result.$3,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            added
                                ? 'Exercício adicionado ao treino.'
                                : 'Este exercício já está no treino.',
                          ),
                        ),
                      );
                      if (added) Navigator.pop(context);
                    },
                  );
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
