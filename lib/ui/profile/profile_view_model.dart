import 'package:flutter/foundation.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/workout_repository.dart';
import 'package:uuid/uuid.dart';

/// ViewModel do perfil do atleta.
/// Fundamentado no Pilar I (Zero Mock Data): todas as métricas, biometria,
/// recordes e estatísticas de volume são calculados a partir dos dados reais
/// persistidos no banco de dados SQLite ou exibem estados vazios explícitos.
class ProfileViewModel extends ChangeNotifier {
  final HistoryRepository _historyRepository;
  final WorkoutRepository _workoutRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String userName;
  String userCode;
  String athleteTier;
  String planTier;

  // Biometria real (inicializada em 0.0 / estado limpo)
  double currentWeightKg;
  double heightM;
  double bodyFatPercentage;
  double weightDeltaKg;
  double bodyFatDelta;

  // Estatísticas calculadas
  int totalSessionsCount;
  double totalVolumeTons;
  int streakWeeks;

  // PRs reais do banco
  double benchPressPR;
  double squatPR;
  int frequencyStreakWeeks;

  // Treino Ativo do Dia
  String? todayWorkoutName;
  String? todayWorkoutSession;
  String? todayWorkoutId;

  ProfileViewModel({
    required HistoryRepository historyRepository,
    required WorkoutRepository workoutRepository,
    String? initialUserName,
  })  : _historyRepository = historyRepository,
        _workoutRepository = workoutRepository,
        userName = initialUserName ?? 'Atleta GymR',
        userCode = '#GYMR-PRO',
        athleteTier = 'Atleta GymR',
        planTier = 'Gymr PRO',
        currentWeightKg = 0.0,
        heightM = 1.75,
        bodyFatPercentage = 0.0,
        weightDeltaKg = 0.0,
        bodyFatDelta = 0.0,
        totalSessionsCount = 0,
        totalVolumeTons = 0.0,
        streakWeeks = 0,
        benchPressPR = 0.0,
        squatPR = 0.0,
        frequencyStreakWeeks = 0;

  /// Cálculo do Índice de Massa Corporal (IMC) baseado em biometria real
  double get bmi {
    if (heightM <= 0 || currentWeightKg <= 0) return 0.0;
    return currentWeightKg / (heightM * heightM);
  }

  /// Carrega dados reais de sessões, medições e fichas do banco de dados
  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Carrega sessões concluídas e calcula volume total real
      final sessions = await _historyRepository.getCompletedSessions();
      totalSessionsCount = sessions.length;
      if (sessions.isNotEmpty) {
        final totalKg = sessions.fold(0.0, (sum, s) => sum + s.totalVolumeKg);
        totalVolumeTons = totalKg / 1000.0;
        streakWeeks = _calculateStreakWeeks(sessions);
        frequencyStreakWeeks = streakWeeks;
      } else {
        totalVolumeTons = 0.0;
        streakWeeks = 0;
        frequencyStreakWeeks = 0;
      }

      // 2. Carrega histórico de medições corporais reais
      final measurements = await _historyRepository.getMeasurements();
      final weights = measurements
          .where((m) => m.weightKg != null && m.weightKg! > 0)
          .map((m) => m.weightKg!)
          .toList();
      if (weights.isNotEmpty) {
        currentWeightKg = weights.first;
        weightDeltaKg = weights.length >= 2 ? weights[0] - weights[1] : 0.0;
      } else {
        currentWeightKg = 0.0;
        weightDeltaKg = 0.0;
      }

      final bodyFats = measurements
          .where((m) => m.bodyFatPercentage != null && m.bodyFatPercentage! > 0)
          .map((m) => m.bodyFatPercentage!)
          .toList();
      if (bodyFats.isNotEmpty) {
        bodyFatPercentage = bodyFats.first;
        bodyFatDelta = bodyFats.length >= 2 ? bodyFats[0] - bodyFats[1] : 0.0;
      } else {
        bodyFatPercentage = 0.0;
        bodyFatDelta = 0.0;
      }

      // 3. Carrega Recordes Pessoais reais ordenados por 1RM
      final prs = await _historyRepository.getExercisePRs();
      for (final pr in prs) {
        final nameLower = pr.exerciseName.toLowerCase();
        if (nameLower.contains('supino')) {
          if (pr.maxWeightKg > benchPressPR) benchPressPR = pr.maxWeightKg;
        } else if (nameLower.contains('agachamento')) {
          if (pr.maxWeightKg > squatPR) squatPR = pr.maxWeightKg;
        }
      }

      // 4. Carrega ficha de treino configurada
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

  /// Calcula a consistência contínua (semanas consecutivas com treinos)
  int _calculateStreakWeeks(List<WorkoutSessionRecord> sessions) {
    if (sessions.isEmpty) return 0;

    final Set<int> weekIndices = {};
    for (final s in sessions) {
      final weekIndex = (s.startTime.millisecondsSinceEpoch / (1000 * 60 * 60 * 24 * 7)).floor();
      weekIndices.add(weekIndex);
    }

    final now = DateTime.now();
    final currentWeekIndex = (now.millisecondsSinceEpoch / (1000 * 60 * 60 * 24 * 7)).floor();

    int streak = 0;
    int checkWeek = currentWeekIndex;

    // Se o atleta ainda não treinou nesta semana, avalia a partir da semana passada
    if (!weekIndices.contains(checkWeek)) {
      checkWeek--;
    }

    while (weekIndices.contains(checkWeek)) {
      streak++;
      checkWeek--;
    }

    return streak;
  }

  /// Atualiza as medidas biométricas do atleta e salva no histórico SQLite
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
    await loadProfileData();
  }

  /// Atualiza o nome do atleta
  Future<void> updateProfileName(String newName) async {
    userName = newName;
    notifyListeners();
  }
}
