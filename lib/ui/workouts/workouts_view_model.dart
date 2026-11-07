import 'package:flutter/foundation.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/workout.dart';

class WorkoutsViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  WorkoutsViewModel({WorkoutRepository? workoutRepository})
      : _workoutRepository = workoutRepository ?? WorkoutRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Workout> _workouts = [];
  List<Workout> get workouts => _workouts;

  String _selectedFilter = 'Todos';
  String get selectedFilter => _selectedFilter;

  List<Workout> get filteredWorkouts {
    if (_selectedFilter == 'Todos') return _workouts;
    return _workouts.where((w) => w.split.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> loadWorkouts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _workouts = await _workoutRepository.getAllWorkouts();
    } catch (e) {
      debugPrint('Erro ao carregar fichas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      await _workoutRepository.deleteWorkout(id);
      await loadWorkouts();
    } catch (e) {
      debugPrint('Erro ao deletar treino: $e');
    }
  }
}
