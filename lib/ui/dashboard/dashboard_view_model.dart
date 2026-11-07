import 'package:flutter/foundation.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/workout.dart';

class DashboardViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  DashboardViewModel({WorkoutRepository? workoutRepository})
      : _workoutRepository = workoutRepository ?? WorkoutRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Workout> _recentWorkouts = [];
  List<Workout> get recentWorkouts => _recentWorkouts;

  Workout? _nextWorkout;
  Workout? get nextWorkout => _nextWorkout;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recentWorkouts = await _workoutRepository.getAllWorkouts();
      if (_recentWorkouts.isNotEmpty) {
        _nextWorkout = _recentWorkouts.first;
      } else {
        _nextWorkout = null;
      }
    } catch (e) {
      debugPrint('Erro ao carregar dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
