import 'package:sqflite/sqflite.dart';
import '../../domain/models/exercise.dart';
import '../database/app_database.dart';

class ExerciseRepository {
  final AppDatabase _dbProvider;

  ExerciseRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<List<Exercise>> getAllExercises() async {
    final db = await _dbProvider.database;
    final maps = await db.query('exercises', orderBy: 'name ASC');
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'exercises',
      where: 'LOWER(muscleGroup) = LOWER(?)',
      whereArgs: [muscleGroup.trim()],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<List<Exercise>> getExercisesByEquipment(String equipment) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'exercises',
      where: 'LOWER(equipment) = LOWER(?)',
      whereArgs: [equipment.trim()],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<List<Exercise>> filterExercises({
    String? muscleGroup,
    String? equipment,
    String? query,
  }) async {
    final db = await _dbProvider.database;

    final clauses = <String>[];
    final whereArgs = <dynamic>[];

    if (muscleGroup != null &&
        muscleGroup.trim().isNotEmpty &&
        muscleGroup.trim().toLowerCase() != 'todos' &&
        muscleGroup.trim().toLowerCase() != 'all') {
      clauses.add('LOWER(muscleGroup) = LOWER(?)');
      whereArgs.add(muscleGroup.trim());
    }

    if (equipment != null &&
        equipment.trim().isNotEmpty &&
        equipment.trim().toLowerCase() != 'todos' &&
        equipment.trim().toLowerCase() != 'all') {
      clauses.add('LOWER(equipment) = LOWER(?)');
      whereArgs.add(equipment.trim());
    }

    if (query != null && query.trim().isNotEmpty) {
      final sanitized = '%${query.trim().toLowerCase()}%';
      clauses.add(
        '(LOWER(name) LIKE ? OR LOWER(muscleGroup) LIKE ? OR LOWER(equipment) LIKE ? OR LOWER(instructions) LIKE ? OR LOWER(secondaryMuscles) LIKE ?)',
      );
      whereArgs.addAll([sanitized, sanitized, sanitized, sanitized, sanitized]);
    }

    final whereString = clauses.isNotEmpty ? clauses.join(' AND ') : null;
    final argsList = whereArgs.isNotEmpty ? whereArgs : null;

    final maps = await db.query(
      'exercises',
      where: whereString,
      whereArgs: argsList,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  Future<Exercise?> getExerciseById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Exercise.fromMap(maps.first);
    }
    return null;
  }

  Future<void> addCustomExercise(Exercise exercise) async {
    final db = await _dbProvider.database;
    await db.insert(
      'exercises',
      exercise.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
