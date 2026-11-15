import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../domain/models/exercise.dart';

class ExerciseCatalogViewModel extends ChangeNotifier {
  final ExerciseRepository _exerciseRepository;

  ExerciseCatalogViewModel({ExerciseRepository? exerciseRepository})
      : _exerciseRepository = exerciseRepository ?? ExerciseRepository();

  Timer? _debounceTimer;
  int _searchSequence = 0;

  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _selectedMuscleGroup = 'Todos';
  String get selectedMuscleGroup => _selectedMuscleGroup;

  String _selectedEquipment = 'Todos';
  String get selectedEquipment => _selectedEquipment;

  String _query = '';
  String get query => _query;

  Future<void> loadExercises() async {
    final currentSeq = ++_searchSequence;
    _isLoading = true;
    notifyListeners();

    try {
      final results = await _exerciseRepository.filterExercises(
        muscleGroup: _selectedMuscleGroup,
        equipment: _selectedEquipment,
        query: _query,
      );
      if (currentSeq == _searchSequence) {
        _exercises = results;
      }
    } catch (e) {
      debugPrint('Erro ao carregar catálogo de exercícios: $e');
    } finally {
      if (currentSeq == _searchSequence) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void onSearchChanged(String value) {
    _query = value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      loadExercises();
    });
  }

  void selectMuscleGroup(String group) {
    if (_selectedMuscleGroup == group) return;
    _debounceTimer?.cancel();
    _selectedMuscleGroup = group;
    loadExercises();
  }

  void selectEquipment(String equipment) {
    if (_selectedEquipment == equipment) return;
    _debounceTimer?.cancel();
    _selectedEquipment = equipment;
    loadExercises();
  }

  void clearFilters() {
    _debounceTimer?.cancel();
    _query = '';
    _selectedMuscleGroup = 'Todos';
    _selectedEquipment = 'Todos';
    loadExercises();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
