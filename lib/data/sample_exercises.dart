import '../models/exercises.dart';
import '../models/muscle_groups.dart';

const sampleExercises = <Exercise>[
  Exercise(
    id: '1',
    name: 'Pulldown',
    muscleGroup: MuscleGroup.back,
    description:
        'Pull the bar down to your chest while keeping your back straight.',
  ),
  Exercise(
    id: '2',
    name: 'Pulley',
    muscleGroup: MuscleGroup.back,
    description:
        'Pull the pulley towards your chest while keeping your elbows close to your body.',
  ),
  Exercise(
    id: '3',
    name: 'Barbell Row',
    muscleGroup: MuscleGroup.back,
    description:
        'Bend over and pull the barbell towards your stomach while keeping your back straight.',
  ),
  Exercise(
    id: '4',
    name: 'Biceps Curl',
    muscleGroup: MuscleGroup.arms,
    description:
        'Curl the dumbbells towards your shoulders while keeping your elbows close to your body.',
  ),
  Exercise(
    id: '5',
    name: 'Hammer Curl',
    muscleGroup: MuscleGroup.arms,
    description:
        'Curl the dumbbells towards your shoulders with your palms facing each other.',
  ),
  Exercise(
    id: '6',
    name: 'Triceps Pushdown',
    muscleGroup: MuscleGroup.arms,
    description:
        'Push the bar down towards your thighs while keeping your elbows close to your body.',
  ),
  Exercise(id: '7', name: 'Bench Press', muscleGroup: MuscleGroup.chest),
  Exercise(
    id: '8',
    name: 'Incline Dumbbell Press',
    muscleGroup: MuscleGroup.chest,
  ),
  Exercise(id: '9', name: 'Squat', muscleGroup: MuscleGroup.legs),
  Exercise(id: '10', name: 'Leg Press', muscleGroup: MuscleGroup.legs),
  Exercise(id: '11', name: 'Lunges', muscleGroup: MuscleGroup.legs),
];
