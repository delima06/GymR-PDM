import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/epley_calculator.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout.dart';

/// Estado de uma série individual dentro da sessão de treino ativo
class ActiveWorkoutSet {
  final int setNumber;
  double weightKg;
  int reps;
  bool isCompleted;

  ActiveWorkoutSet({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.isCompleted = false,
  });
}

/// Exercício ativo com suas séries associadas
class ActiveExerciseItem {
  final WorkoutExercise exercise;
  final List<ActiveWorkoutSet> sets;

  ActiveExerciseItem({
    required this.exercise,
    required this.sets,
  });
}

class ActiveWorkoutViewModel extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;
  final AppDatabase _dbProvider;

  ActiveWorkoutViewModel({
    WorkoutRepository? workoutRepository,
    AppDatabase? dbProvider,
  })  : _workoutRepository = workoutRepository ?? WorkoutRepository(),
        _dbProvider = dbProvider ?? AppDatabase.instance;

  // Treino e Exercícios
  Workout? _workout;
  Workout? get workout => _workout;

  List<ActiveExerciseItem> _exerciseItems = [];
  List<ActiveExerciseItem> get exerciseItems => _exerciseItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSessionActive = false;
  bool get isSessionActive => _isSessionActive;

  int _sessionNonce = 0;
  int get sessionNonce => _sessionNonce;

  DateTime? _sessionStartTime;
  int _sessionElapsedSeconds = 0;
  int get sessionElapsedSeconds => _sessionElapsedSeconds;
  Timer? _sessionTimer;

  // Cronômetro Regressivo de Descanso
  int _restInitialSeconds = 60;
  int get restInitialSeconds => _restInitialSeconds;

  int _restSecondsRemaining = 0;
  int get restSecondsRemaining => _restSecondsRemaining;

  bool _isRestActive = false;
  bool get isRestActive => _isRestActive;
  Timer? _restTimer;
  AudioPlayer? _audioPlayer;

  String get formattedSessionDuration {
    final hours = (_sessionElapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_sessionElapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_sessionElapsedSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String get formattedRestRemaining {
    final minutes = (_restSecondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_restSecondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get restProgress {
    if (_restInitialSeconds == 0) return 0;
    return (_restInitialSeconds - _restSecondsRemaining) / _restInitialSeconds;
  }

  /// Inicializa o treino ativo com o ID especificado
  Future<void> startWorkoutSession(String? workoutId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (workoutId != null) {
        _workout = await _workoutRepository.getWorkoutById(workoutId);
      } else {
        final all = await _workoutRepository.getAllWorkouts();
        _workout = all.isNotEmpty ? all.first : null;
      }

      if (_workout != null) {
        _exerciseItems = _buildExerciseItems(_workout!);
      } else {
        _exerciseItems = [];
      }

      _startSessionClock();
    } catch (e) {
      debugPrint('Erro ao iniciar treino ativo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Inicia a sessão de treino ativo diretamente a partir de um objeto Workout em memória
  void startSessionWithWorkout(Workout workout) {
    _workout = workout;
    _exerciseItems = _buildExerciseItems(workout);
    _startSessionClock();
    notifyListeners();
  }

  List<ActiveExerciseItem> _buildExerciseItems(Workout workout) {
    return workout.exercises.map((we) {
      final clampedSets = we.targetSets > 0 ? we.targetSets : 1;
      final clampedReps = we.maxReps > 0 ? we.maxReps : 1;
      final sets = List.generate(
        clampedSets,
        (index) => ActiveWorkoutSet(
          setNumber: index + 1,
          weightKg: we.initialWeight,
          reps: clampedReps,
          isCompleted: false,
        ),
      );
      return ActiveExerciseItem(exercise: we, sets: sets);
    }).toList();
  }

  void _startSessionClock() {
    _sessionNonce++;
    _sessionStartTime = DateTime.now();
    _sessionElapsedSeconds = 0;
    _isSessionActive = true;
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _sessionElapsedSeconds++;
      notifyListeners();
    });
  }

  /// Marca ou desmarca uma série como concluída
  void toggleSetCompleted(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _exerciseItems.length) return;
    final item = _exerciseItems[exerciseIndex];
    if (setIndex < 0 || setIndex >= item.sets.length) return;

    final targetSet = item.sets[setIndex];
    targetSet.isCompleted = !targetSet.isCompleted;

    // Se marcou como concluída, dispara automaticamente o timer de descanso!
    if (targetSet.isCompleted) {
      startRestTimer(item.exercise.restSeconds);
    }

    notifyListeners();
  }

  /// Atualiza o peso de uma série específica
  void updateSetWeight(int exerciseIndex, int setIndex, double weight) {
    if (exerciseIndex < 0 || exerciseIndex >= _exerciseItems.length) return;
    final item = _exerciseItems[exerciseIndex];
    if (setIndex < 0 || setIndex >= item.sets.length) return;
    item.sets[setIndex].weightKg = weight;
    notifyListeners();
  }

  /// Atualiza as repetições de uma série específica
  void updateSetReps(int exerciseIndex, int setIndex, int reps) {
    if (exerciseIndex < 0 || exerciseIndex >= _exerciseItems.length) return;
    final item = _exerciseItems[exerciseIndex];
    if (setIndex < 0 || setIndex >= item.sets.length) return;
    item.sets[setIndex].reps = reps;
    notifyListeners();
  }

  /// Inicia o timer regressivo de descanso
  void startRestTimer(int seconds) {
    _restTimer?.cancel();
    _restInitialSeconds = seconds > 0 ? seconds : 60;
    _restSecondsRemaining = _restInitialSeconds;
    _isRestActive = true;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 1) {
        _restSecondsRemaining--;
        notifyListeners();
      } else {
        _restSecondsRemaining = 0;
        _isRestActive = false;
        timer.cancel();
        // Feedback tátil e sonoro offline (chime local + fallback nativo)
        unawaited(_playRestDoneCue());
        notifyListeners();
      }
    });
  }

  Future<void> _playRestDoneCue() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
    await runZonedGuarded(() async {
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer!.setVolume(1.0);
      await _audioPlayer!.play(AssetSource('audio/rest_timer_done.wav'));
    }, (_, __) {});
  }

  /// Adiciona uma nova série extra ao exercício em tempo de treino
  void addExtraSet(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _exerciseItems.length) return;
    final item = _exerciseItems[exerciseIndex];
    final lastSet = item.sets.isNotEmpty ? item.sets.last : null;
    final newNumber = item.sets.length + 1;
    final weight = lastSet?.weightKg ?? item.exercise.initialWeight;
    final reps = lastSet?.reps ?? item.exercise.maxReps;

    item.sets.add(
      ActiveWorkoutSet(
        setNumber: newNumber,
        weightKg: weight,
        reps: reps,
        isCompleted: false,
      ),
    );
    notifyListeners();
  }

  /// Remove a última série do exercício (caso tenha adicionado sem querer)
  void removeLastSet(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= _exerciseItems.length) return;
    final item = _exerciseItems[exerciseIndex];
    if (item.sets.length > 1) {
      item.sets.removeLast();
      notifyListeners();
    }
  }

  /// Adiciona mais tempo ao descanso (ex: +30 segundos)
  void addRestSeconds(int extraSeconds) {
    _restSecondsRemaining += extraSeconds;
    _restInitialSeconds += extraSeconds;
    notifyListeners();
  }

  /// Pula o descanso imediatamente
  void skipRest() {
    _restTimer?.cancel();
    _restSecondsRemaining = 0;
    _isRestActive = false;
    notifyListeners();
  }

  /// Finaliza o treino, calcula volume total e persiste no SQLite
  Future<bool> finishWorkout() async {
    _sessionTimer?.cancel();
    _restTimer?.cancel();

    double totalVolume = 0;
    final List<Map<String, dynamic>> setsToSave = [];
    final sessionId = const Uuid().v4();

    for (final item in _exerciseItems) {
      for (final s in item.sets) {
        if (s.isCompleted) {
          totalVolume += (s.weightKg * s.reps);
          // Estimativa de 1RM com fórmula de Epley: Peso * (1 + Reps / 30)
          final epley1RM = EpleyCalculator.calculate1RM(s.weightKg, s.reps);

          setsToSave.add({
            'id': const Uuid().v4(),
            'sessionId': sessionId,
            'exerciseId': item.exercise.exerciseId,
            'setNumber': s.setNumber,
            'weightKg': s.weightKg,
            'reps': s.reps,
            'completed': 1,
            'timestamp': DateTime.now().toIso8601String(),
            'estimated1RM': epley1RM,
          });
        }
      }
    }

    try {
      final db = await _dbProvider.database;
      await db.transaction((txn) async {
        await txn.insert('workout_sessions', {
          'id': sessionId,
          'workoutId': _workout?.id,
          'workoutName': _workout?.name ?? 'Treino Livre',
          'startTime': (_sessionStartTime ?? DateTime.now()).toIso8601String(),
          'endTime': DateTime.now().toIso8601String(),
          'durationSeconds': _sessionElapsedSeconds,
          'totalVolumeKg': totalVolume,
          'completed': 1,
        });

        for (final setMap in setsToSave) {
          await txn.insert('workout_sets', setMap);
        }
      });

      _isSessionActive = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao finalizar sessão: $e');
      return false;
    }
  }

  Future<Exercise?> getExerciseDetails(String exerciseId) async {
    final repo = ExerciseRepository(dbProvider: _dbProvider);
    return await repo.getExerciseById(exerciseId);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _restTimer?.cancel();
    try {
      _audioPlayer?.dispose();
    } catch (_) {}
    super.dispose();
  }
}

