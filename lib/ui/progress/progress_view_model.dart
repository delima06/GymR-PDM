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

  Future<void> loadProgressData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sessions = await _historyRepository.getCompletedSessions();
      _prs = await _historyRepository.getExercisePRs();
      _measurements = await _historyRepository.getMeasurements();
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
  }) async {
    final record = MeasurementRecord(
      id: const Uuid().v4(),
      date: DateTime.now(),
      weightKg: weightKg,
      bodyFatPercentage: bodyFatPercentage,
      armsCm: armsCm,
      waistCm: waistCm,
      chestCm: chestCm,
    );

    try {
      await _historyRepository.saveMeasurement(record);
      await loadProgressData();
    } catch (e) {
      debugPrint('Erro ao salvar medida: $e');
    }
  }
}

