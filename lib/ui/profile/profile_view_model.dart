import 'package:flutter/foundation.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/workout_repository.dart';
import 'package:uuid/uuid.dart';

class ProfileViewModel extends ChangeNotifier {
  final HistoryRepository _historyRepository;
  final WorkoutRepository _workoutRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String userName = 'Michael Law';
  String userCode = '#GYMR-9042';
  String athleteTier = 'Atleta Intermediário';
  String planTier = 'Gymr PRO';

  // Biometria
  double currentWeightKg = 78.4;
  double heightM = 1.78;
  double bodyFatPercentage = 12.8;
  double weightDeltaKg = -2.1;
  double bodyFatDelta = -1.4;

  // Estatísticas
  int totalSessionsCount = 142;
  double totalVolumeTons = 18.4;
  int streakWeeks = 12;

  // PRs
  double benchPressPR = 100.0;
  double squatPR = 140.0;
  int frequencyStreakWeeks = 12;

  // Próximo Treino
  String? todayWorkoutName = 'Peito & Tríceps';
  String? todayWorkoutSession = 'Sessão B';
  String? todayWorkoutId;

  ProfileViewModel({
    required HistoryRepository historyRepository,
    required WorkoutRepository workoutRepository,
  })  : _historyRepository = historyRepository,
        _workoutRepository = workoutRepository;

  double get bmi {
    if (heightM <= 0) return 24.7;
    return currentWeightKg / (heightM * heightM);
  }

  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Carrega sessões concluídas
      final sessions = await _historyRepository.getCompletedSessions();
      if (sessions.isNotEmpty) {
        totalSessionsCount = sessions.length;
        final totalKg = sessions.fold(0.0, (sum, s) => sum + s.totalVolumeKg);
        totalVolumeTons = (totalKg / 1000.0);
        if (totalVolumeTons < 0.1) totalVolumeTons = 18.4;
      }

      // 2. Carrega medições
      final measurements = await _historyRepository.getMeasurements();
      if (measurements.isNotEmpty) {
        final latest = measurements.first;
        if (latest.weightKg != null && latest.weightKg! > 0) {
          currentWeightKg = latest.weightKg!;
        }
        if (latest.bodyFatPercentage != null && latest.bodyFatPercentage! > 0) {
          bodyFatPercentage = latest.bodyFatPercentage!;
        }

        if (measurements.length >= 2) {
          final prev = measurements[1];
          if (prev.weightKg != null && latest.weightKg != null) {
            weightDeltaKg = latest.weightKg! - prev.weightKg!;
          }
          if (prev.bodyFatPercentage != null && latest.bodyFatPercentage != null) {
            bodyFatDelta = latest.bodyFatPercentage! - prev.bodyFatPercentage!;
          }
        }
      }

      // 3. Carrega PRs
      final prs = await _historyRepository.getExercisePRs();
      for (final pr in prs) {
        final nameLower = pr.exerciseName.toLowerCase();
        if (nameLower.contains('supino')) {
          if (pr.maxWeightKg > benchPressPR) benchPressPR = pr.maxWeightKg;
        } else if (nameLower.contains('agachamento')) {
          if (pr.maxWeightKg > squatPR) squatPR = pr.maxWeightKg;
        }
      }

      // 4. Carrega treino de hoje
      final workouts = await _workoutRepository.getAllWorkouts();
      if (workouts.isNotEmpty) {
        todayWorkoutId = workouts.first.id;
        todayWorkoutName = workouts.first.name;
        todayWorkoutSession = 'Sessão ${workouts.first.split}';
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBiometrics({
    required double weight,
    required double height,
    required double bodyFat,
  }) async {
    currentWeightKg = weight;
    heightM = height;
    bodyFatPercentage = bodyFat;

    final record = MeasurementRecord(
      id: const Uuid().v4(),
      date: DateTime.now(),
      weightKg: weight,
      bodyFatPercentage: bodyFat,
    );

    await _historyRepository.saveMeasurement(record);
    notifyListeners();
  }

  Future<void> updateProfileName(String newName) async {
    userName = newName;
    notifyListeners();
  }
}
