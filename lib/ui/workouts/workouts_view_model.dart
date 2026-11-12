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

  int _selectedWorkoutIndex = 0;
  int get selectedWorkoutIndex => _selectedWorkoutIndex;

  Workout? get selectedWorkout {
    if (_workouts.isEmpty) return null;
    final index = _selectedWorkoutIndex.clamp(0, _workouts.length - 1);
    return _workouts[index];
  }

  void selectWorkout(int index) {
    _selectedWorkoutIndex = index;
    notifyListeners();
  }

  Future<void> loadWorkouts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _workouts = await _workoutRepository.getAllWorkouts();
      if (_selectedWorkoutIndex >= _workouts.length) {
        _selectedWorkoutIndex = 0;
      }
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

  Future<void> removeExerciseFromSelectedWorkout(String exerciseId) async {
    final current = selectedWorkout;
    if (current == null) return;

    final updatedExercises = current.exercises.where((e) => e.id != exerciseId).toList();
    final updatedWorkout = current.copyWith(exercises: updatedExercises);
    await _workoutRepository.saveWorkout(updatedWorkout);
    await loadWorkouts();
  }
}
