import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../core/utils/epley_calculator.dart';
import '../database/app_database.dart';

class WorkoutSessionRecord {
  final String id;
  final String workoutName;
  final DateTime startTime;
  final int durationSeconds;
  final double totalVolumeKg;

  WorkoutSessionRecord({
    required this.id,
    required this.workoutName,
    required this.startTime,
    required this.durationSeconds,
    required this.totalVolumeKg,
  });

  String get formattedDuration {
    final minutes = (durationSeconds / 60).floor();
    return '${minutes}m';
  }
}

class ExercisePRRecord {
  final String exerciseId;
  final String exerciseName;
  final double maxWeightKg;
  final int maxRepsAtMaxWeight;
  final double estimated1RM;
  final bool shouldProgressWeight; // Se atingiu o topo da faixa de repetições

  ExercisePRRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.maxWeightKg,
    required this.maxRepsAtMaxWeight,
    required this.estimated1RM,
    required this.shouldProgressWeight,
  });

  double get suggestedNextWeightKg => EpleyCalculator.suggestNextWeight(maxWeightKg);
}

class MeasurementRecord {
  final String id;
  final DateTime date;
  final double? weightKg;
  final double? bodyFatPercentage;
  final double? armsCm;
  final double? waistCm;
  final double? chestCm;
  final double? thighsCm;
  final double? calvesCm;
  final List<String> photoPaths;

  MeasurementRecord({
    required this.id,
    required this.date,
    this.weightKg,
    this.bodyFatPercentage,
    this.armsCm,
    this.waistCm,
    this.chestCm,
    this.thighsCm,
    this.calvesCm,
    this.photoPaths = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'bodyFatPercentage': bodyFatPercentage,
      'armsCm': armsCm,
      'waistCm': waistCm,
      'chestCm': chestCm,
      'thighsCm': thighsCm,
      'calvesCm': calvesCm,
      'photoPaths': photoPaths.isEmpty ? null : jsonEncode(photoPaths),
    };
  }

  factory MeasurementRecord.fromMap(Map<String, dynamic> map) {
    List<String> photos = const [];
    final rawPhotos = map['photoPaths'];
    if (rawPhotos is String && rawPhotos.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPhotos);
        if (decoded is List) {
          photos = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        photos = rawPhotos.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    } else if (rawPhotos is List) {
      photos = rawPhotos.map((e) => e.toString()).toList();
    }

    return MeasurementRecord(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      bodyFatPercentage: (map['bodyFatPercentage'] as num?)?.toDouble(),
      armsCm: (map['armsCm'] as num?)?.toDouble(),
      waistCm: (map['waistCm'] as num?)?.toDouble(),
      chestCm: (map['chestCm'] as num?)?.toDouble(),
      thighsCm: (map['thighsCm'] as num?)?.toDouble(),
      calvesCm: (map['calvesCm'] as num?)?.toDouble(),
      photoPaths: photos,
    );
  }
}

class ExerciseLoadPoint {
  final double weightKg;
  final int reps;
  final double estimated1RM;
  final DateTime date;

  ExerciseLoadPoint({
    required this.weightKg,
    required this.reps,
    required this.estimated1RM,
    required this.date,
  });
}

class HistoryRepository {
  final AppDatabase _dbProvider;

  HistoryRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  /// Retorna as sessões de treino concluídas
  Future<List<WorkoutSessionRecord>> getCompletedSessions() async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'workout_sessions',
      where: 'completed = 1',
      orderBy: 'startTime DESC',
    );

    return maps.map((map) {
      return WorkoutSessionRecord(
        id: map['id'] as String,
        workoutName: map['workoutName'] as String,
        startTime: DateTime.parse(map['startTime'] as String),
        durationSeconds: (map['durationSeconds'] as int?) ?? 0,
        totalVolumeKg: (map['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  /// Calcula Recorde Pessoal (PR) e 1RM por exercício ordenado pelo maior 1RM estimado
  Future<List<ExercisePRRecord>> getExercisePRs() async {
    final db = await _dbProvider.database;

    // Busca séries concluídas para todos os exercícios com a meta de repetições da ficha
    final sets = await db.rawQuery('''
      SELECT ws.exerciseId, e.name as exerciseName, ws.weightKg, ws.reps, ws.estimated1RM,
             (SELECT MAX(we.maxReps) FROM workout_exercises we WHERE we.exerciseId = ws.exerciseId) as targetMaxReps
      FROM workout_sets ws
      JOIN exercises e ON ws.exerciseId = e.id
      WHERE ws.completed = 1
    ''');

    // Mapeia todas as séries e calcula 1RM científico exato
    final List<Map<String, dynamic>> enrichedSets = sets.map((row) {
      final weight = (row['weightKg'] as num).toDouble();
      final reps = (row['reps'] as num).toInt();
      final targetMaxReps = (row['targetMaxReps'] as num?)?.toInt() ?? 12;
      final stored1RM = (row['estimated1RM'] as num?)?.toDouble();
      final e1RM = stored1RM != null && stored1RM > 0
          ? stored1RM
          : EpleyCalculator.calculate1RM(weight, reps);
      return {
        'exerciseId': row['exerciseId'] as String,
        'exerciseName': row['exerciseName'] as String,
        'weightKg': weight,
        'reps': reps,
        'targetMaxReps': targetMaxReps,
        'estimated1RM': e1RM,
      };
    }).toList();

    // Ordena por maior 1RM estimado, com desempate pela maior carga bruta
    enrichedSets.sort((a, b) {
      final cmp1RM = (b['estimated1RM'] as double).compareTo(a['estimated1RM'] as double);
      if (cmp1RM != 0) return cmp1RM;
      return (b['weightKg'] as double).compareTo(a['weightKg'] as double);
    });

    final Map<String, ExercisePRRecord> prMap = {};

    for (final row in enrichedSets) {
      final exId = row['exerciseId'] as String;
      final exName = row['exerciseName'] as String;
      final weight = row['weightKg'] as double;
      final reps = row['reps'] as int;
      final targetMaxReps = row['targetMaxReps'] as int;
      final e1RM = row['estimated1RM'] as double;

      if (!prMap.containsKey(exId)) {
        final shouldProgress = EpleyCalculator.shouldProgressWeight(
          reps,
          targetMaxReps,
        );

        prMap[exId] = ExercisePRRecord(
          exerciseId: exId,
          exerciseName: exName,
          maxWeightKg: weight,
          maxRepsAtMaxWeight: reps,
          estimated1RM: e1RM,
          shouldProgressWeight: shouldProgress,
        );
      }
    }

    final prList = prMap.values.toList();
    prList.sort((a, b) => b.estimated1RM.compareTo(a.estimated1RM));
    return prList;
  }

  /// Salva uma nova medição antropométrica
  Future<void> saveMeasurement(MeasurementRecord measurement) async {
    final db = await _dbProvider.database;
    await db.insert(
      'measurements',
      measurement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retorna as medições registradas em ordem decrescente de data
  Future<List<MeasurementRecord>> getMeasurements() async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'measurements',
      orderBy: 'date DESC',
    );
    return maps.map((m) => MeasurementRecord.fromMap(m)).toList();
  }

  /// Retorna os pontos de carga históricos ordenados por tempo para o gráfico
  Future<List<ExerciseLoadPoint>> getExerciseLoadHistory(String exerciseName) async {
    final db = await _dbProvider.database;
    final results = await db.rawQuery('''
      SELECT ws.weightKg, ws.reps, ws.estimated1RM, ws.timestamp
      FROM workout_sets ws
      JOIN exercises e ON ws.exerciseId = e.id
      WHERE (e.name LIKE ? OR ? LIKE '%' || e.name || '%') AND ws.completed = 1
      ORDER BY ws.timestamp ASC
    ''', ['%$exerciseName%', exerciseName]);

    return results.map((r) {
      final weight = (r['weightKg'] as num).toDouble();
      final reps = (r['reps'] as num).toInt();
      final e1RM = (r['estimated1RM'] as num?)?.toDouble() ??
          EpleyCalculator.calculate1RM(weight, reps);
      final date = DateTime.tryParse(r['timestamp'] as String? ?? '') ?? DateTime.now();

      return ExerciseLoadPoint(
        weightKg: weight,
        reps: reps,
        estimated1RM: e1RM,
        date: date,
      );
    }).toList();
  }
}

