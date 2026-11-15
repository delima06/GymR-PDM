import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymr/core/utils/epley_calculator.dart';
import 'package:gymr/data/repositories/history_repository.dart';
import 'package:gymr/data/repositories/workout_repository.dart';
import 'package:gymr/ui/profile/profile_view_model.dart';
import 'package:gymr/ui/progress/comparative_photo_view.dart';
import 'package:gymr/ui/progress/progress_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  group('Milestone 3 — EpleyCalculator & Sobrecarga Progressiva Científica', () {
    test('calculate1RM calcula 1RM com precisão pela fórmula de Epley', () {
      expect(EpleyCalculator.calculate1RM(100.0, 1), 100.0);
      expect(EpleyCalculator.calculate1RM(100.0, 10), closeTo(133.33, 0.01));
      expect(EpleyCalculator.calculate1RM(0.0, 10), 0.0);
      expect(EpleyCalculator.calculate1RM(-50.0, 5), 0.0);
    });

    test('shouldProgressWeight avalia targetMaxReps customizado ou padrão 12', () {
      // Padrão (targetMaxReps = 12)
      expect(EpleyCalculator.shouldProgressWeight(11), isFalse);
      expect(EpleyCalculator.shouldProgressWeight(12), isTrue);
      expect(EpleyCalculator.shouldProgressWeight(14), isTrue);

      // Customizado (ex: faixa de força 6 reps, ou hipertrofia 8 reps)
      expect(EpleyCalculator.shouldProgressWeight(5, 6), isFalse);
      expect(EpleyCalculator.shouldProgressWeight(6, 6), isTrue);
      expect(EpleyCalculator.shouldProgressWeight(7, 8), isFalse);
      expect(EpleyCalculator.shouldProgressWeight(8, 8), isTrue);
      expect(EpleyCalculator.shouldProgressWeight(0, 8), isFalse);
    });

    test('suggestNextWeight calcula incremento gradual e seguro de carga (+2.5 kg padrão)', () {
      expect(EpleyCalculator.suggestNextWeight(80.0), 82.5);
      expect(EpleyCalculator.suggestNextWeight(100.0), 102.5);
      expect(EpleyCalculator.suggestNextWeight(0.0), 2.5);
      expect(EpleyCalculator.suggestNextWeight(60.0, 5.0), 65.0);
    });
  });

  group('Milestone 3 — HistoryRepository & MeasurementRecord Extension', () {
    test('MeasurementRecord serializa e desserializa thighsCm, calvesCm e photoPaths', () {
      final now = DateTime.now();
      final record = MeasurementRecord(
        id: 'm-test-1',
        date: now,
        weightKg: 82.5,
        bodyFatPercentage: 14.5,
        armsCm: 39.0,
        waistCm: 81.0,
        chestCm: 104.0,
        thighsCm: 60.5,
        calvesCm: 38.5,
        photoPaths: ['assets/images/athlete_avatar.png', '/data/photo_1.jpg'],
      );

      final map = record.toMap();
      expect(map['id'], 'm-test-1');
      expect(map['thighsCm'], 60.5);
      expect(map['calvesCm'], 38.5);
      expect(map['photoPaths'], contains('athlete_avatar.png'));

      final restored = MeasurementRecord.fromMap(map);
      expect(restored.id, 'm-test-1');
      expect(restored.thighsCm, 60.5);
      expect(restored.calvesCm, 38.5);
      expect(restored.photoPaths.length, 2);
      expect(restored.photoPaths.first, 'assets/images/athlete_avatar.png');
    });

    test('MeasurementRecord fromMap lida defensivamente com photoPaths nulo ou string vazia', () {
      final map = {
        'id': 'm-empty',
        'date': DateTime.now().toIso8601String(),
        'weightKg': 75.0,
        'photoPaths': null,
      };

      final restored = MeasurementRecord.fromMap(map);
      expect(restored.photoPaths, isEmpty);
      expect(restored.thighsCm, isNull);
      expect(restored.calvesCm, isNull);
    });
  });

  group('Milestone 3 — ProfileViewModel Zero Mock Data (Pilar I)', () {
    test('ProfileViewModel inicializa com estado vazio limpo e sem mock data fake', () {
      final vm = ProfileViewModel(
        historyRepository: HistoryRepository(),
        workoutRepository: WorkoutRepository(),
      );

      expect(vm.userName, 'Atleta GymR');
      expect(vm.totalVolumeTons, 0.0);
      expect(vm.totalSessionsCount, 0);
      expect(vm.streakWeeks, 0);
      expect(vm.benchPressPR, 0.0);
      expect(vm.squatPR, 0.0);
      expect(vm.currentWeightKg, 0.0);
      expect(vm.weightDeltaKg, 0.0);
      expect(vm.bodyFatDelta, 0.0);
      expect(vm.bmi, 0.0);
    });

    test('updateProfileName altera o nome do atleta e notifica ouvintes', () {
      final vm = ProfileViewModel(
        historyRepository: HistoryRepository(),
        workoutRepository: WorkoutRepository(),
      );

      bool notified = false;
      vm.addListener(() => notified = true);

      vm.updateProfileName('Lucas Silva');
      expect(vm.userName, 'Lucas Silva');
      expect(notified, isTrue);
    });
  });

  group('Milestone 3 — ComparativePhotoView & Progress Integration', () {
    testWidgets('ComparativePhotoView renderiza estado vazio quando não há fotos', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final progressVm = ProgressViewModel(
        historyRepository: HistoryRepository(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ProgressViewModel>.value(
            value: progressVm,
            child: const ComparativePhotoView(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Galeria Comparativa'), findsOneWidget);
      expect(find.text('NOVA FOTO'), findsOneWidget);
      expect(find.text('Nenhuma Foto de Evolução'), findsOneWidget);
      expect(find.text('REGISTRAR PRIMEIRA FOTO'), findsOneWidget);
    });
  });
}
