import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/history_repository.dart';

class ProgressViewModel extends ChangeNotifier {
  final HistoryRepository _historyRepository;

  ProgressViewModel({HistoryRepository? historyRepository})
      : _historyRepository = historyRepository ?? HistoryRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<WorkoutSessionRecord> _sessions = [];
  List<WorkoutSessionRecord> get sessions => _sessions;

  List<ExercisePRRecord> _prs = [];
  List<ExercisePRRecord> get prs => _prs;

  List<MeasurementRecord> _measurements = [];
  List<MeasurementRecord> get measurements => _measurements;

  double? get latestWeight => _measurements.isNotEmpty ? _measurements.first.weightKg : null;
  double? get latestArms => _measurements.isNotEmpty ? _measurements.first.armsCm : null;
  double? get latestWaist => _measurements.isNotEmpty ? _measurements.first.waistCm : null;
  double? get latestBodyFat => _measurements.isNotEmpty ? _measurements.first.bodyFatPercentage : null;
  double? get latestThighs => _measurements.isNotEmpty ? _measurements.first.thighsCm : null;
  double? get latestCalves => _measurements.isNotEmpty ? _measurements.first.calvesCm : null;

  double? _computeDelta(double? Function(MeasurementRecord) selector) {
    if (_measurements.length < 2) return null;
    final curr = selector(_measurements[0]);
    final prev = selector(_measurements[1]);
    if (curr == null || prev == null) return null;
    return curr - prev;
  }

  double? get deltaWeight => _computeDelta((m) => m.weightKg);
  double? get deltaArms => _computeDelta((m) => m.armsCm);
  double? get deltaWaist => _computeDelta((m) => m.waistCm);
  double? get deltaBodyFat => _computeDelta((m) => m.bodyFatPercentage);
  double? get deltaThighs => _computeDelta((m) => m.thighsCm);
  double? get deltaCalves => _computeDelta((m) => m.calvesCm);

  List<ExerciseLoadPoint> _selectedExercisePoints = [];
  List<ExerciseLoadPoint> get selectedExercisePoints => _selectedExercisePoints;
  String _selectedExerciseName = 'Supino Reto com Barra';
  String get selectedExerciseName => _selectedExerciseName;

  Future<void> selectExerciseForChart(String exerciseName) async {
    _selectedExerciseName = exerciseName;
    _selectedExercisePoints = await _historyRepository.getExerciseLoadHistory(exerciseName);
    notifyListeners();
  }

  Future<void> loadProgressData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sessions = await _historyRepository.getCompletedSessions();
      _prs = await _historyRepository.getExercisePRs();
      _measurements = await _historyRepository.getMeasurements();
      _selectedExercisePoints = await _historyRepository.getExerciseLoadHistory(_selectedExerciseName);
    } catch (e) {
      debugPrint('Erro ao carregar histórico: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMeasurement({
    double? weightKg,
    double? bodyFatPercentage,
    double? armsCm,
    double? waistCm,
    double? chestCm,
    double? thighsCm,
    double? calvesCm,
    List<String>? photoPaths,
  }) async {
    final record = MeasurementRecord(
      id: const Uuid().v4(),
      date: DateTime.now(),
      weightKg: weightKg,
      bodyFatPercentage: bodyFatPercentage,
      armsCm: armsCm,
      waistCm: waistCm,
      chestCm: chestCm,
      thighsCm: thighsCm,
      calvesCm: calvesCm,
      photoPaths: photoPaths ?? const [],
    );

    try {
      await _historyRepository.saveMeasurement(record);
      await loadProgressData();
    } catch (e) {
      debugPrint('Erro ao salvar medida: $e');
    }
  }
}

