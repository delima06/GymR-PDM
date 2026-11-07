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
      where: 'muscleGroup = ?',
      whereArgs: [muscleGroup],
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
