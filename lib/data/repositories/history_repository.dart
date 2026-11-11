import 'package:sqflite/sqflite.dart';
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
  final bool shouldProgressWeight; // Se atingiu 12+ reps na carga máxima

  ExercisePRRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.maxWeightKg,
    required this.maxRepsAtMaxWeight,
    required this.estimated1RM,
    required this.shouldProgressWeight,
  });
}

class MeasurementRecord {
  final String id;
  final DateTime date;
  final double? weightKg;
  final double? bodyFatPercentage;
  final double? armsCm;
  final double? waistCm;
  final double? chestCm;

  MeasurementRecord({
    required this.id,
    required this.date,
    this.weightKg,
    this.bodyFatPercentage,
    this.armsCm,
    this.waistCm,
    this.chestCm,
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
    };
  }

  factory MeasurementRecord.fromMap(Map<String, dynamic> map) {
    return MeasurementRecord(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      bodyFatPercentage: (map['bodyFatPercentage'] as num?)?.toDouble(),
      armsCm: (map['armsCm'] as num?)?.toDouble(),
      waistCm: (map['waistCm'] as num?)?.toDouble(),
      chestCm: (map['chestCm'] as num?)?.toDouble(),
    );
  }
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

  /// Calcula Recorde Pessoal (PR) e 1RM por exercício
  Future<List<ExercisePRRecord>> getExercisePRs() async {
    final db = await _dbProvider.database;

    // Busca exercícios que têm séries registradas
    final sets = await db.rawQuery('''
      SELECT ws.exerciseId, e.name as exerciseName, ws.weightKg, ws.reps, ws.estimated1RM
      FROM workout_sets ws
      JOIN exercises e ON ws.exerciseId = e.id
      WHERE ws.completed = 1
      ORDER BY ws.weightKg DESC, ws.reps DESC
    ''');

    final Map<String, ExercisePRRecord> prMap = {};

    for (final row in sets) {
      final exId = row['exerciseId'] as String;
      final exName = row['exerciseName'] as String;
      final weight = (row['weightKg'] as num).toDouble();
      final reps = row['reps'] as int;
      final e1RM = (row['estimated1RM'] as num?)?.toDouble() ?? (reps > 1 ? weight * (1 + (reps / 30.0)) : weight);

      if (!prMap.containsKey(exId)) {
        // Sugestão de progressão: se fez 12 ou mais repetições na carga mais pesada, sugere subir peso!
        final shouldProgress = reps >= 12;

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

    return prMap.values.toList();
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
}

