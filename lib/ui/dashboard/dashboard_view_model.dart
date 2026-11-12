import 'package:flutter/foundation.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/repositories/history_repository.dart';
import '../../domain/models/workout.dart';

class DashboardViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final HistoryRepository _historyRepository;

  DashboardViewModel({
    WorkoutRepository? workoutRepository,
    HistoryRepository? historyRepository,
  })  : _workoutRepository = workoutRepository ?? WorkoutRepository(),
        _historyRepository = historyRepository ?? HistoryRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Workout> _recentWorkouts = [];
  List<Workout> get recentWorkouts => _recentWorkouts;

  Workout? _nextWorkout;
  Workout? get nextWorkout => _nextWorkout;

  double _weeklyVolumeKg = 0.0;
  double get weeklyVolumeKg => _weeklyVolumeKg;

  int _weeklyDurationSeconds = 0;
  int get weeklyDurationSeconds => _weeklyDurationSeconds;

  int _completedSessionsCount = 0;
  int get completedSessionsCount => _completedSessionsCount;

  String get formattedActiveTime {
    if (_weeklyDurationSeconds == 0) return '0h 0m';
    final hours = _weeklyDurationSeconds ~/ 3600;
    final minutes = (_weeklyDurationSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recentWorkouts = await _workoutRepository.getAllWorkouts();
      _nextWorkout = _recentWorkouts.isNotEmpty ? _recentWorkouts.first : null;

      final sessions = await _historyRepository.getCompletedSessions();
      _completedSessionsCount = sessions.length;

      // Calcular volume e tempo reais acumulados
      _weeklyVolumeKg = sessions.fold(0.0, (acc, s) => acc + s.totalVolumeKg);
      _weeklyDurationSeconds = sessions.fold(0, (acc, s) => acc + s.durationSeconds);
    } catch (e) {
      debugPrint('Erro ao carregar dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
