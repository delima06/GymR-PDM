/// Exercício configurado dentro de uma ficha de treino
class WorkoutExercise {
  final String id;
  final String workoutId;
  final String exerciseId;
  final String exerciseName;
  final int targetSets; // Ex: 4 séries
  final int minReps; // Ex: 8 repetições
  final int maxReps; // Ex: 12 repetições
  final double initialWeight; // Em kg
  final int restSeconds; // Ex: 90 segundos
  final int orderIndex;

  const WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseName,
    required this.targetSets,
    required this.minReps,
    required this.maxReps,
    required this.initialWeight,
    required this.restSeconds,
    this.orderIndex = 0,
  });

  String get repRangeText => '$minReps - $maxReps';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutId': workoutId,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'targetSets': targetSets,
      'minReps': minReps,
      'maxReps': maxReps,
      'initialWeight': initialWeight,
      'restSeconds': restSeconds,
      'orderIndex': orderIndex,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id: map['id'] as String,
      workoutId: map['workoutId'] as String,
      exerciseId: map['exerciseId'] as String,
      exerciseName: map['exerciseName'] as String,
      targetSets: map['targetSets'] as int,
      minReps: map['minReps'] as int,
      maxReps: map['maxReps'] as int,
      initialWeight: (map['initialWeight'] as num).toDouble(),
      restSeconds: map['restSeconds'] as int,
      orderIndex: map['orderIndex'] as int? ?? 0,
    );
  }
}

/// Ficha de Treino (Rotina como Treino A, Upper, Full Body)
class Workout {
  final String id;
  final String name;
  final String? description;
  final String split; // Ex: ABC, Upper/Lower, Full Body
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;

  const Workout({
    required this.id,
    required this.name,
    this.description,
    this.split = 'ABC',
    this.exercises = const [],
    required this.createdAt,
  });

  Workout copyWith({
    String? id,
    String? name,
    String? description,
    String? split,
    List<WorkoutExercise>? exercises,
    DateTime? createdAt,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      split: split ?? this.split,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'split': split,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map, {List<WorkoutExercise> exercises = const []}) {
    return Workout(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      split: map['split'] as String? ?? 'ABC',
      exercises: exercises,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
