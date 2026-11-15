import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gymr/domain/models/workout.dart';
import 'package:gymr/ui/active_workout/active_workout_view.dart';
import 'package:gymr/ui/active_workout/active_workout_view_model.dart';
import 'package:gymr/ui/workouts/create_workout_view.dart';
import 'package:gymr/ui/workouts/workouts_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone 2 - Workouts and Active Workout Enhancements', () {
    test('WorkoutsView.formatChipLabel formats distinct labels for split and name', () {
      final workoutA = Workout(
        id: 'w1',
        name: 'Treino A',
        split: 'ABC',
        createdAt: DateTime.now(),
      );
      final workoutB = Workout(
        id: 'w2',
        name: 'Treino B',
        split: 'ABC',
        createdAt: DateTime.now(),
      );
      final workoutFull = Workout(
        id: 'w3',
        name: 'Full Body',
        split: 'Full Body',
        createdAt: DateTime.now(),
      );
      final workoutUnnamed = Workout(
        id: 'w4',
        name: '',
        split: '',
        createdAt: DateTime.now(),
      );

      // Directly exercises production method WorkoutsView.formatChipLabel
      expect(WorkoutsView.formatChipLabel(workoutA, 0), equals('ABC • Treino A'));
      expect(WorkoutsView.formatChipLabel(workoutB, 1), equals('ABC • Treino B'));
      expect(WorkoutsView.formatChipLabel(workoutFull, 2), equals('Full Body'));
      expect(WorkoutsView.formatChipLabel(workoutUnnamed, 3), equals('Treino 4'));
      expect(WorkoutsView.formatChipLabel(workoutA, 0), isNot(equals(WorkoutsView.formatChipLabel(workoutB, 1))));
    });

    test('CreateWorkoutView validates rep range and target sets from production code', () {
      // Directly exercises production validation methods
      expect(CreateWorkoutView.isValidRepRange(8, 12), isTrue);
      expect(CreateWorkoutView.isValidRepRange(10, 10), isTrue);
      expect(CreateWorkoutView.isValidRepRange(15, 10), isFalse);
      expect(CreateWorkoutView.isValidRepRange(12, 8), isFalse);
      expect(CreateWorkoutView.isValidRepRange(0, 10), isFalse);
      expect(CreateWorkoutView.isValidRepRange(-1, 10), isFalse);

      expect(CreateWorkoutView.isValidTargetSets(3), isTrue);
      expect(CreateWorkoutView.isValidTargetSets(1), isTrue);
      expect(CreateWorkoutView.isValidTargetSets(0), isFalse);
      expect(CreateWorkoutView.isValidTargetSets(-2), isFalse);
    });

    test('ActiveWorkoutViewModel invokes SystemSound.play(alert) and HapticFeedback.vibrate on rest expiry', () async {
      final List<String> channelCalls = [];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          channelCalls.add(methodCall.method);
          return null;
        },
      );

      final vm = ActiveWorkoutViewModel();
      vm.startRestTimer(1);

      expect(vm.isRestActive, isTrue);

      // Wait for timer to tick down and expire
      await Future.delayed(const Duration(milliseconds: 1200));

      expect(vm.isRestActive, isFalse);
      expect(vm.restSecondsRemaining, equals(0));
      expect(channelCalls, contains('HapticFeedback.vibrate'));
      expect(channelCalls, contains('SystemSound.play'));

      vm.dispose();
    });

    test('ActiveWorkoutViewModel clamps targetSets and maxReps to minimum 1', () {
      final vm = ActiveWorkoutViewModel();
      final corruptedWorkout = Workout(
        id: 'w_corrupt',
        name: 'Treino Inválido',
        createdAt: DateTime.now(),
        exercises: const [
          WorkoutExercise(
            id: 'we_neg',
            workoutId: 'w_corrupt',
            exerciseId: 'ex_neg',
            exerciseName: 'Exercício Zero',
            targetSets: 0,
            minReps: -5,
            maxReps: 0,
            initialWeight: 10,
            restSeconds: 30,
          ),
        ],
      );

      // Does not throw ArgumentError on List.generate
      expect(() => vm.startSessionWithWorkout(corruptedWorkout), returnsNormally);
      expect(vm.exerciseItems.first.sets.length, equals(1));
      expect(vm.exerciseItems.first.sets.first.reps, equals(1));

      vm.dispose();
    });

    testWidgets('ActiveWorkoutView renders authentic ValueKeys and handles duplicate exercises without key collision', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vm = ActiveWorkoutViewModel();
      final workout = Workout(
        id: 'w_test_01',
        name: 'Treino A',
        split: 'ABC',
        createdAt: DateTime.now(),
        exercises: const [
          WorkoutExercise(
            id: 'we_01',
            workoutId: 'w_test_01',
            exerciseId: 'ex_supino_01',
            exerciseName: 'Supino Reto',
            targetSets: 2,
            minReps: 8,
            maxReps: 12,
            initialWeight: 60.0,
            restSeconds: 60,
          ),
          // Duplicate exercise to verify key collision prevention
          WorkoutExercise(
            id: 'we_02',
            workoutId: 'w_test_01',
            exerciseId: 'ex_supino_01',
            exerciseName: 'Supino Reto (Drop)',
            targetSets: 1,
            minReps: 10,
            maxReps: 15,
            initialWeight: 40.0,
            restSeconds: 45,
          ),
        ],
      );

      vm.startSessionWithWorkout(workout);

      await tester.pumpWidget(
        ChangeNotifierProvider<ActiveWorkoutViewModel>.value(
          value: vm,
          child: const MaterialApp(
            home: ActiveWorkoutView(),
          ),
        ),
      );
      await tester.pump();

      // Verify exercise cards exist for both exercises (disambiguated by exIndex)
      expect(find.byKey(const ValueKey('exercise_card_ex_supino_01_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('exercise_card_ex_supino_01_1')), findsOneWidget);

      // Verify set rows, input fields, and check buttons for Exercise 0, Set 0
      expect(find.byKey(const ValueKey('set_row_ex_supino_01_0_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('weight_field_ex_supino_01_0_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('reps_field_ex_supino_01_0_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('check_button_ex_supino_01_0_0')), findsOneWidget);

      // Verify set rows, input fields, and check buttons for Exercise 1 (duplicate), Set 0
      expect(find.byKey(const ValueKey('set_row_ex_supino_01_1_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('weight_field_ex_supino_01_1_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('reps_field_ex_supino_01_1_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('check_button_ex_supino_01_1_0')), findsOneWidget);

      // Verify live interaction: tapping check button completes the set
      expect(vm.exerciseItems[0].sets[0].isCompleted, isFalse);
      await tester.tap(find.byKey(const ValueKey('check_button_ex_supino_01_0_0')));
      await tester.pump();
      expect(vm.exerciseItems[0].sets[0].isCompleted, isTrue);

      vm.dispose();
    });

    test('ActiveWorkoutViewModel defensive guards prevent RangeError on negative and out-of-bounds indices', () {
      final vm = ActiveWorkoutViewModel();
      final workout = Workout(
        id: 'w_guard',
        name: 'Treino Teste',
        createdAt: DateTime.now(),
        exercises: const [
          WorkoutExercise(
            id: 'we_guard',
            workoutId: 'w_guard',
            exerciseId: 'ex_guard',
            exerciseName: 'Agachamento Livre',
            targetSets: 2,
            minReps: 6,
            maxReps: 10,
            initialWeight: 100.0,
            restSeconds: 120,
          ),
        ],
      );

      vm.startSessionWithWorkout(workout);

      // Negative indices must safely return without throwing RangeError
      expect(() => vm.toggleSetCompleted(-1, 0), returnsNormally);
      expect(() => vm.toggleSetCompleted(0, -1), returnsNormally);
      expect(() => vm.updateSetWeight(-1, 0, 50.0), returnsNormally);
      expect(() => vm.updateSetWeight(0, -1, 50.0), returnsNormally);
      expect(() => vm.updateSetReps(-1, 0, 8), returnsNormally);
      expect(() => vm.updateSetReps(0, -1, 8), returnsNormally);
      expect(() => vm.addExtraSet(-1), returnsNormally);
      expect(() => vm.removeLastSet(-1), returnsNormally);

      // Out of bounds positive indices
      expect(() => vm.toggleSetCompleted(99, 0), returnsNormally);
      expect(() => vm.toggleSetCompleted(0, 99), returnsNormally);
      expect(() => vm.updateSetWeight(99, 0, 50.0), returnsNormally);
      expect(() => vm.updateSetWeight(0, 99, 50.0), returnsNormally);
      expect(() => vm.updateSetReps(99, 0, 8), returnsNormally);
      expect(() => vm.updateSetReps(0, 99, 8), returnsNormally);
      expect(() => vm.addExtraSet(99), returnsNormally);
      expect(() => vm.removeLastSet(99), returnsNormally);

      vm.dispose();
    });

    testWidgets('CreateWorkoutView exercise config dialog dismisses cleanly without controller disposal exceptions', (tester) async {
      final workout = Workout(
        id: 'w_test_dialog',
        name: 'Treino A',
        split: 'ABC',
        createdAt: DateTime.now(),
        exercises: const [
          WorkoutExercise(
            id: 'we_dialog_1',
            workoutId: 'w_test_dialog',
            exerciseId: 'ex_supino',
            exerciseName: 'Supino Reto',
            targetSets: 3,
            minReps: 8,
            maxReps: 12,
            initialWeight: 60.0,
            restSeconds: 60,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreateWorkoutView(workoutToEdit: workout),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Open dialog and dismiss via CANCELAR button
      await tester.tap(find.text('Supino Reto'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Supino Reto'), findsOneWidget);
      expect(find.text('CANCELAR'), findsOneWidget);

      await tester.tap(find.text('CANCELAR'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Editar Supino Reto'), findsNothing);

      // 2. Open dialog and dismiss via modal barrier tap
      await tester.tap(find.text('Supino Reto'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Supino Reto'), findsOneWidget);

      // Tap outside dialog on barrier
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Editar Supino Reto'), findsNothing);
    });

    testWidgets('ActiveWorkoutView renders on narrow 360x800 viewport with long name and active rest card without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final vm = ActiveWorkoutViewModel();
      final workout = Workout(
        id: 'w_long_name',
        name: 'Treino A - Peito, Ombros e Tríceps com Sobrecarga Progressiva Avançada',
        split: 'Push / Pull / Legs Hipertrofia',
        createdAt: DateTime.now(),
        exercises: const [
          WorkoutExercise(
            id: 'we_01',
            workoutId: 'w_long_name',
            exerciseId: 'ex_01',
            exerciseName: 'Supino Inclinado com Halteres',
            targetSets: 3,
            minReps: 8,
            maxReps: 12,
            initialWeight: 32.0,
            restSeconds: 90,
          ),
        ],
      );

      vm.startSessionWithWorkout(workout);
      vm.startRestTimer(90);

      await tester.pumpWidget(
        ChangeNotifierProvider<ActiveWorkoutViewModel>.value(
          value: vm,
          child: const MaterialApp(
            home: ActiveWorkoutView(),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('INTERVALO DE DESCANSO'), findsOneWidget);
      expect(find.text('EM ANDAMENTO'), findsOneWidget);

      vm.skipRest();
      vm.dispose();
    });

    testWidgets('CreateWorkoutView renders on narrow viewport without overflow on header', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreateWorkoutView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Exercícios Selecionados'), findsOneWidget);
    });
  });
}
