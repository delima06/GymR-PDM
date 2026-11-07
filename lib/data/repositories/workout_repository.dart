import 'package:sqflite/sqflite.dart';
import '../../domain/models/workout.dart';
import '../database/app_database.dart';

class WorkoutRepository {
  final AppDatabase _dbProvider;

  WorkoutRepository({AppDatabase? dbProvider})
      : _dbProvider = dbProvider ?? AppDatabase.instance;

  Future<List<Workout>> getAllWorkouts() async {
    final db = await _dbProvider.database;
    final workoutMaps = await db.query('workouts', orderBy: 'createdAt DESC');

    final List<Workout> workouts = [];
    for (final map in workoutMaps) {
      final workoutId = map['id'] as String;
      final exercisesMaps = await db.query(
        'workout_exercises',
        where: 'workoutId = ?',
        whereArgs: [workoutId],
        orderBy: 'orderIndex ASC',
      );
      final exercises = exercisesMaps.map((e) => WorkoutExercise.fromMap(e)).toList();
      workouts.add(Workout.fromMap(map, exercises: exercises));
    }

    return workouts;
  }

  Future<Workout?> getWorkoutById(String id) async {
    final db = await _dbProvider.database;
    final workoutMaps = await db.query(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (workoutMaps.isEmpty) return null;

    final exercisesMaps = await db.query(
      'workout_exercises',
      where: 'workoutId = ?',
      whereArgs: [id],
      orderBy: 'orderIndex ASC',
    );
    final exercises = exercisesMaps.map((e) => WorkoutExercise.fromMap(e)).toList();
    return Workout.fromMap(workoutMaps.first, exercises: exercises);
  }

  Future<void> saveWorkout(Workout workout) async {
    final db = await _dbProvider.database;

    await db.transaction((txn) async {
      await txn.insert(
        'workouts',
        workout.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Deleta exercícios anteriores associados a este workout para atualizar a lista
      await txn.delete(
        'workout_exercises',
        where: 'workoutId = ?',
        whereArgs: [workout.id],
      );

      for (int i = 0; i < workout.exercises.length; i++) {
        final exercise = workout.exercises[i];
        final exerciseMap = exercise.toMap();
        exerciseMap['orderIndex'] = i;
        await txn.insert('workout_exercises', exerciseMap);
      }
    });
  }

  Future<void> deleteWorkout(String workoutId) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await txn.delete(
        'workout_exercises',
        where: 'workoutId = ?',
        whereArgs: [workoutId],
      );
      await txn.delete(
        'workouts',
        where: 'id = ?',
        whereArgs: [workoutId],
      );
    });
  }
}
