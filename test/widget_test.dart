import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_app/main.dart';
import 'package:gym_tracker_app/controllers/workout_controller.dart';
import 'package:gym_tracker_app/repositories/workout_repository.dart';
import 'package:gym_tracker_app/pages/workouts_page.dart';
import 'package:gym_tracker_app/widgets/create_workout_dialog.dart';
import 'package:gym_tracker_app/widgets/workout_card_empty.dart';

void main() {
  test(
    'Creation trims names, rejects invalid input and preserves unique IDs',
    () {
      final controller = WorkoutController(WorkoutRepository());
      final initialCount = controller.getAllWorkouts().length;
      expect(controller.createWorkout('  '), isFalse);
      expect(controller.createWorkout(' push DAY '), isFalse);
      expect(controller.createWorkout('  Upper Body  '), isTrue);
      expect(controller.createWorkout('upper body'), isFalse);
      expect(controller.createWorkout('Lower Body'), isTrue);
      final workouts = controller.getAllWorkouts();
      expect(workouts.length, initialCount + 2);
      expect(workouts[initialCount].name, 'Upper Body');
      expect(
        workouts.map((workout) => workout.id).toSet().length,
        workouts.length,
      );
    },
  );

  testWidgets(
    'Invalid names show errors and correction creates a single workout',
    (tester) async {
      final controller = WorkoutController(WorkoutRepository());
      await tester.pumpWidget(
        MaterialApp(home: WorkoutsPage(controller: controller)),
      );
      await tester.tap(find.text('New Workout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create'));
      await tester.pump();
      expect(find.text('Enter a workout name.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), ' push day ');
      await tester.tap(find.text('Create'));
      await tester.pump();
      expect(
        find.text('A workout with this name already exists.'),
        findsOneWidget,
      );
      expect(controller.getAllWorkouts().length, 3);
      await tester.enterText(find.byType(TextFormField), '  Upper Body  ');
      final save = tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Create'))
          .onPressed!;
      save();
      save();
      await tester.pumpAndSettle();
      expect(find.byType(CreateWorkoutDialog), findsNothing);
      expect(find.text('Upper Body'), findsOneWidget);
      expect(controller.getAllWorkouts().length, 4);
    },
  );

  testWidgets('Only one dialog opens and cancel or dismissal creates nothing', (
    tester,
  ) async {
    final controller = WorkoutController(WorkoutRepository());
    await tester.pumpWidget(
      MaterialApp(home: WorkoutsPage(controller: controller)),
    );
    final open = tester
        .widget<WorkoutCardEmpty>(find.byType(WorkoutCardEmpty))
        .onTap;
    open();
    open();
    await tester.pumpAndSettle();
    expect(find.byType(CreateWorkoutDialog), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Cancelled');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateWorkoutDialog), findsNothing);
    expect(controller.getAllWorkouts().length, 3);
    await tester.tap(find.text('New Workout'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(CreateWorkoutDialog), findsNothing);
    expect(controller.getAllWorkouts().length, 3);
  });

  testWidgets('Created workout is available on Home and after changing tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Workouts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Workout'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Full Body');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Full Body'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Full Body'), findsOneWidget);
    await tester.tap(find.text('Workouts'));
    await tester.pumpAndSettle();
    expect(find.text('Full Body'), findsOneWidget);
  });

  testWidgets(
    'Removing page while dialog is open does not create or update disposed state',
    (tester) async {
      final controller = WorkoutController(WorkoutRepository());
      final visible = ValueNotifier(true);
      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (context, show, child) => show
                ? WorkoutsPage(controller: controller)
                : const Scaffold(body: Text('Page removed')),
          ),
        ),
      );
      await tester.tap(find.text('New Workout'));
      await tester.pumpAndSettle();
      visible.value = false;
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'Orphan workout');
      await tester.tap(find.text('Create'));
      await tester.pump();
      expect(find.text('This page is no longer available.'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(controller.getAllWorkouts().length, 3);
      await tester.pumpWidget(const SizedBox.shrink());
      visible.dispose();
    },
  );
}
