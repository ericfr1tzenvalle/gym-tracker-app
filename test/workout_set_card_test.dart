import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_app/widgets/workout_set_card.dart';

void main() {
  testWidgets('rejects zero reps and zero weight independently', (
    tester,
  ) async {
    final registered = <(double, int)>[];
    await tester.binding.setSurfaceSize(const Size(440, 900));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WorkoutSetCard(
              setNumber: 1,
              plannedSets: 3,
              plannedRepetitions: 12,
              numberOfExercises: 1,
              exerciseIndex: 0,
              exerciseName: 'Supino',
              weight: null,
              repetitions: null,
              onRegister: (weight, repetitions) {
                registered.add((weight, repetitions));
                return true;
              },
            ),
          ),
        ),
      ),
    );
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '10');
    await tester.enterText(fields.at(1), '0');
    await tester.tap(find.text('Register set'));
    await tester.pump();
    expect(registered, isEmpty);
    await tester.enterText(fields.at(1), '10');
    await tester.enterText(fields.at(0), '0');
    await tester.tap(find.text('Register set'));
    await tester.pump();
    expect(registered, isEmpty);
    await tester.enterText(fields.at(0), '10');
    await tester.tap(find.text('Register set'));
    await tester.pump();
    expect(registered, [(10.0, 10)]);
    await tester.binding.setSurfaceSize(null);
  });
}
