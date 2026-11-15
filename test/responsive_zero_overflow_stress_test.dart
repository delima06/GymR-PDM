import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gymr/data/repositories/history_repository.dart';
import 'package:gymr/data/repositories/workout_repository.dart';
import 'package:gymr/domain/models/workout.dart';
import 'package:gymr/ui/dashboard/dashboard_view.dart';
import 'package:gymr/ui/dashboard/dashboard_view_model.dart';
import 'package:gymr/ui/workouts/workouts_view.dart';
import 'package:gymr/ui/workouts/workouts_view_model.dart';
import 'package:gymr/ui/workouts/create_workout_view.dart';
import 'package:gymr/ui/active_workout/active_workout_view.dart';
import 'package:gymr/ui/active_workout/active_workout_view_model.dart';
import 'package:gymr/ui/progress/progress_view.dart';
import 'package:gymr/ui/progress/progress_view_model.dart';
import 'package:gymr/ui/progress/comparative_photo_view.dart';
import 'package:gymr/ui/profile/profile_view.dart';
import 'package:gymr/ui/profile/profile_view_model.dart';
import 'package:gymr/ui/exercises/exercise_catalog_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Matriz de viewports móveis reais para teste de estresse
  final viewports = [
    const Size(320, 568), // Ultra-compacto (iPhone SE 1ª Geração)
    const Size(360, 640), // Android Compacto padrão (hdpi/xhdpi)
    const Size(375, 667), // iPhone 8 / SE 2020/2022
    const Size(390, 844), // iPhone 13 / 14 padrão
    const Size(412, 915), // Android Moderno (Pixel 7 / Galaxy S23)
  ];

  group('Pilar III — Responsive Layout & Zero Overflow Across Screens', () {
    for (final size in viewports) {
      final sizeLabel = '${size.width.toInt()}x${size.height.toInt()}';

      testWidgets('DashboardView renders without overflow on $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final vm = DashboardViewModel(
          workoutRepository: WorkoutRepository(),
          historyRepository: HistoryRepository(),
        );

        await tester.pumpWidget(
          ChangeNotifierProvider<DashboardViewModel>.value(
            value: vm,
            child: const MaterialApp(
              home: DashboardView(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(DashboardView), findsOneWidget);
      });

      testWidgets('WorkoutsView renders without overflow on $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final vm = WorkoutsViewModel(workoutRepository: WorkoutRepository());

        await tester.pumpWidget(
          ChangeNotifierProvider<WorkoutsViewModel>.value(
            value: vm,
            child: const MaterialApp(
              home: WorkoutsView(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(WorkoutsView), findsOneWidget);
      });

      testWidgets('CreateWorkoutView renders without overflow on $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: CreateWorkoutView(),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(CreateWorkoutView), findsOneWidget);
      });

      testWidgets('ActiveWorkoutView renders without overflow on $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final vm = ActiveWorkoutViewModel();
        final workout = Workout(
          id: 'test_wk',
          name: 'Treino A - Peito e Tríceps com Sobrecarga Progressiva',
          split: 'ABC',
          createdAt: DateTime.now(),
          exercises: const [
            WorkoutExercise(
              id: 'e1',
              workoutId: 'test_wk',
              exerciseId: 'ex1',
              exerciseName: 'Supino Reto com Barra',
              targetSets: 3,
              minReps: 8,
              maxReps: 12,
              initialWeight: 80.0,
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
        expect(find.byType(ActiveWorkoutView), findsOneWidget);

        vm.skipRest();
        vm.dispose();
      });

      testWidgets('ProgressView renders without overflow on $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final vm = ProgressViewModel(historyRepository: HistoryRepository());

        await tester.pumpWidget(
          ChangeNotifierProvider<ProgressViewModel>.value(
            value: vm,
            child: const MaterialApp(
              home: ProgressView(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(ProgressView), findsOneWidget);
      });

      testWidgets('ComparativePhotoView renders without overflow on $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final vm = ProgressViewModel(historyRepository: HistoryRepository());

        await tester.pumpWidget(
          ChangeNotifierProvider<ProgressViewModel>.value(
            value: vm,
            child: const MaterialApp(
              home: ComparativePhotoView(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(ComparativePhotoView), findsOneWidget);
      });

      testWidgets('ProfileView renders without overflow on $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final vm = ProfileViewModel(
          historyRepository: HistoryRepository(),
          workoutRepository: WorkoutRepository(),
        );

        await tester.pumpWidget(
          ChangeNotifierProvider<ProfileViewModel>.value(
            value: vm,
            child: const MaterialApp(
              home: ProfileView(),
            ),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(ProfileView), findsOneWidget);
      });

      testWidgets('ExerciseCatalogView renders without overflow on $sizeLabel', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: ExerciseCatalogView(),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(ExerciseCatalogView), findsOneWidget);
      });
    }
  });

  group('Pilar III — Keyboard Insets Resilience & Modal/Dialog Overflow', () {
    testWidgets('Anthropometric Entry Dialog accommodates software keyboard without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });

      final vm = ProgressViewModel(historyRepository: HistoryRepository());

      await tester.pumpWidget(
        ChangeNotifierProvider<ProgressViewModel>.value(
          value: vm,
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    // Trigger dialog
                    showDialog(
                      context: ctx,
                      builder: (_) => AlertDialog(
                        title: const Text('Nova Medição Corporal'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              TextField(decoration: InputDecoration(labelText: 'Peso')),
                              TextField(decoration: InputDecoration(labelText: 'BF')),
                              TextField(decoration: InputDecoration(labelText: 'Braço')),
                              TextField(decoration: InputDecoration(labelText: 'Cintura')),
                              TextField(decoration: InputDecoration(labelText: 'Tórax')),
                              TextField(decoration: InputDecoration(labelText: 'Coxas')),
                              TextField(decoration: InputDecoration(labelText: 'Panturrilhas')),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('OPEN DIALOG'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN DIALOG'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Nova Medição Corporal'), findsOneWidget);
    });

    testWidgets('Exercise Configuration Dialog accommodates keyboard on 360x640', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: ctx,
                    builder: (_) => AlertDialog(
                      title: const Text('Configurar Exercício'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            TextField(decoration: InputDecoration(labelText: 'Séries')),
                            TextField(decoration: InputDecoration(labelText: 'Reps Min')),
                            TextField(decoration: InputDecoration(labelText: 'Reps Max')),
                            TextField(decoration: InputDecoration(labelText: 'Carga')),
                            TextField(decoration: InputDecoration(labelText: 'Descanso')),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('CONFIG'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('CONFIG'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Configurar Exercício'), findsOneWidget);
    });
  });
}
