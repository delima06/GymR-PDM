import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/models/exercise.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gymr.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          final countResult = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM workouts'),
          );
          if (countResult == null || countResult == 0) {
            await _seedDefaultWorkouts(db);
          }
        }
        if (oldVersion < 3) {
          final measurementCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM measurements'),
          );
          if (measurementCount == null || measurementCount == 0) {
            await _seedInitialMeasurements(db);
          }
          final sessionCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM workout_sessions'),
          );
          if (sessionCount == null || sessionCount == 0) {
            await _seedInitialSessions(db);
          }
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabela de Exercícios (Catálogo)
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        muscleGroup TEXT NOT NULL,
        equipment TEXT NOT NULL,
        instructions TEXT,
        secondaryMuscles TEXT,
        mediaUrl TEXT,
        isCustom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 2. Tabela de Fichas de Treino
    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        split TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // 3. Tabela de Exercícios da Ficha
    await db.execute('''
      CREATE TABLE workout_exercises (
        id TEXT PRIMARY KEY,
        workoutId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        exerciseName TEXT NOT NULL,
        targetSets INTEGER NOT NULL,
        minReps INTEGER NOT NULL,
        maxReps INTEGER NOT NULL,
        initialWeight REAL NOT NULL,
        restSeconds INTEGER NOT NULL,
        orderIndex INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (workoutId) REFERENCES workouts (id) ON DELETE CASCADE
      )
    ''');

    // 4. Tabela de Sessões de Treino Ativo (Histórico)
    await db.execute('''
      CREATE TABLE workout_sessions (
        id TEXT PRIMARY KEY,
        workoutId TEXT,
        workoutName TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        durationSeconds INTEGER DEFAULT 0,
        totalVolumeKg REAL DEFAULT 0,
        completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 5. Tabela de Séries Realizadas (Logs)
    await db.execute('''
      CREATE TABLE workout_sets (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        exerciseId TEXT NOT NULL,
        setNumber INTEGER NOT NULL,
        weightKg REAL NOT NULL,
        reps INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 1,
        timestamp TEXT NOT NULL,
        estimated1RM REAL,
        FOREIGN KEY (sessionId) REFERENCES workout_sessions (id) ON DELETE CASCADE
      )
    ''');

    // 6. Tabela de Antropometria (Medidas)
    await db.execute('''
      CREATE TABLE measurements (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        weightKg REAL,
        bodyFatPercentage REAL,
        chestCm REAL,
        armsCm REAL,
        waistCm REAL,
        thighsCm REAL,
        calvesCm REAL,
        photoPaths TEXT
      )
    ''');

    // Seed inicial com catálogo padrão e fichas de exemplo (Stitch)
    await _seedExercises(db);
    await _seedDefaultWorkouts(db);
    await _seedInitialMeasurements(db);
    await _seedInitialSessions(db);
  }

  Future<void> _seedInitialMeasurements(Database db) async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final yesterday = now.subtract(const Duration(days: 1));

    await db.insert('measurements', {
      'id': 'm-baseline',
      'date': thirtyDaysAgo.toIso8601String(),
      'weightKg': 80.5,
      'bodyFatPercentage': 16.0,
      'chestCm': 100.0,
      'armsCm': 38.3,
      'waistCm': 82.5,
      'thighsCm': 58.0,
      'calvesCm': 37.5,
      'photoPaths': null,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('measurements', {
      'id': 'm-current',
      'date': yesterday.toIso8601String(),
      'weightKg': 78.4,
      'bodyFatPercentage': 14.8,
      'chestCm': 102.5,
      'armsCm': 39.5,
      'waistCm': 79.0,
      'thighsCm': 59.5,
      'calvesCm': 38.0,
      'photoPaths': null,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _seedInitialSessions(Database db) async {
    final now = DateTime.now();
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    final fourDaysAgo = now.subtract(const Duration(days: 4));

    // Sessão 1 (4 dias atrás): Treino B
    await db.insert('workout_sessions', {
      'id': 'session-seed-1',
      'workoutId': 'workout-b',
      'workoutName': 'Treino B - Costas & Bíceps',
      'startTime': fourDaysAgo.toIso8601String(),
      'endTime': fourDaysAgo.add(const Duration(minutes: 58)).toIso8601String(),
      'durationSeconds': 3480, // 58 min
      'totalVolumeKg': 7400.0,
      'completed': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Séries da Sessão 1
    await db.insert('workout_sets', {
      'id': 'ws-seed-1',
      'sessionId': 'session-seed-1',
      'exerciseId': 'ex-2',
      'setNumber': 1,
      'weightKg': 60.0,
      'reps': 10,
      'completed': 1,
      'timestamp': fourDaysAgo.toIso8601String(),
      'estimated1RM': 80.0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Sessão 2 (2 dias atrás): Treino A
    await db.insert('workout_sessions', {
      'id': 'session-seed-2',
      'workoutId': 'workout-a',
      'workoutName': 'Treino A - Peito, Ombros & Tríceps',
      'startTime': twoDaysAgo.toIso8601String(),
      'endTime': twoDaysAgo.add(const Duration(minutes: 62)).toIso8601String(),
      'durationSeconds': 3720, // 62 min
      'totalVolumeKg': 8200.0,
      'completed': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Séries da Sessão 2
    await db.insert('workout_sets', {
      'id': 'ws-seed-2',
      'sessionId': 'session-seed-2',
      'exerciseId': 'ex-1',
      'setNumber': 1,
      'weightKg': 80.0,
      'reps': 8,
      'completed': 1,
      'timestamp': twoDaysAgo.toIso8601String(),
      'estimated1RM': 101.3,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _seedDefaultWorkouts(Database db) async {
    // Fichas pré-configuradas idênticas ao design do Stitch (Treino A, B e C)
    final now = DateTime.now().toIso8601String();

    await db.insert('workouts', {
      'id': 'workout-a',
      'name': 'Treino A - Peito, Ombros & Tríceps',
      'description': 'Foco em hipertrofia e empurrar (Push)',
      'split': 'ABC',
      'createdAt': now,
    });

    final exercisesA = [
      {
        'id': 'we-a-1',
        'workoutId': 'workout-a',
        'exerciseId': 'ex-1',
        'exerciseName': 'Supino Reto com Barra',
        'targetSets': 4,
        'minReps': 8,
        'maxReps': 10,
        'initialWeight': 80.0,
        'restSeconds': 90,
        'orderIndex': 0,
      },
      {
        'id': 'we-a-2',
        'workoutId': 'workout-a',
        'exerciseId': 'ex-2',
        'exerciseName': 'Supino Inclinado c/ Halteres',
        'targetSets': 3,
        'minReps': 10,
        'maxReps': 12,
        'initialWeight': 28.0,
        'restSeconds': 75,
        'orderIndex': 1,
      },
      {
        'id': 'we-a-3',
        'workoutId': 'workout-a',
        'exerciseId': 'ex-9',
        'exerciseName': 'Desenvolvimento Militar',
        'targetSets': 4,
        'minReps': 8,
        'maxReps': 10,
        'initialWeight': 20.0,
        'restSeconds': 90,
        'orderIndex': 2,
      },
      {
        'id': 'we-a-4',
        'workoutId': 'workout-a',
        'exerciseId': 'ex-10',
        'exerciseName': 'Elevação Lateral na Polia',
        'targetSets': 4,
        'minReps': 12,
        'maxReps': 15,
        'initialWeight': 12.0,
        'restSeconds': 60,
        'orderIndex': 3,
      },
      {
        'id': 'we-a-5',
        'workoutId': 'workout-a',
        'exerciseId': 'ex-12',
        'exerciseName': 'Tríceps Corda na Polia',
        'targetSets': 3,
        'minReps': 12,
        'maxReps': 15,
        'initialWeight': 25.0,
        'restSeconds': 60,
        'orderIndex': 4,
      },
    ];

    for (final e in exercisesA) {
      await db.insert('workout_exercises', e);
    }

    // Treino B - Costas e Bíceps (Pull)
    await db.insert('workouts', {
      'id': 'workout-b',
      'name': 'Treino B - Costas & Bíceps',
      'description': 'Foco em puxadas e largura de dorsais (Pull)',
      'split': 'ABC',
      'createdAt': now,
    });

    final exercisesB = [
      {
        'id': 'we-b-1',
        'workoutId': 'workout-b',
        'exerciseId': 'ex-4',
        'exerciseName': 'Puxada Aberta na Frente',
        'targetSets': 4,
        'minReps': 10,
        'maxReps': 12,
        'initialWeight': 65.0,
        'restSeconds': 90,
        'orderIndex': 0,
      },
      {
        'id': 'we-b-2',
        'workoutId': 'workout-b',
        'exerciseId': 'ex-5',
        'exerciseName': 'Remada Curvada com Barra',
        'targetSets': 4,
        'minReps': 8,
        'maxReps': 10,
        'initialWeight': 70.0,
        'restSeconds': 90,
        'orderIndex': 1,
      },
      {
        'id': 'we-b-3',
        'workoutId': 'workout-b',
        'exerciseId': 'ex-11',
        'exerciseName': 'Rosca Direta com Barra W',
        'targetSets': 3,
        'minReps': 10,
        'maxReps': 12,
        'initialWeight': 30.0,
        'restSeconds': 60,
        'orderIndex': 2,
      },
    ];

    for (final e in exercisesB) {
      await db.insert('workout_exercises', e);
    }

    // Treino C - Pernas & Core (Legs)
    await db.insert('workouts', {
      'id': 'workout-c',
      'name': 'Treino C - Pernas & Core',
      'description': 'Inferiores completos e estabilidade central (Legs)',
      'split': 'ABC',
      'createdAt': now,
    });

    final exercisesC = [
      {
        'id': 'we-c-1',
        'workoutId': 'workout-c',
        'exerciseId': 'ex-6',
        'exerciseName': 'Agachamento Livre com Barra',
        'targetSets': 4,
        'minReps': 8,
        'maxReps': 10,
        'initialWeight': 90.0,
        'restSeconds': 120,
        'orderIndex': 0,
      },
      {
        'id': 'we-c-2',
        'workoutId': 'workout-c',
        'exerciseId': 'ex-7',
        'exerciseName': 'Leg Press 45°',
        'targetSets': 4,
        'minReps': 10,
        'maxReps': 12,
        'initialWeight': 200.0,
        'restSeconds': 90,
        'orderIndex': 1,
      },
      {
        'id': 'we-c-3',
        'workoutId': 'workout-c',
        'exerciseId': 'ex-13',
        'exerciseName': 'Prancha Isométrica',
        'targetSets': 3,
        'minReps': 45,
        'maxReps': 60,
        'initialWeight': 0.0,
        'restSeconds': 60,
        'orderIndex': 2,
      },
    ];

    for (final e in exercisesC) {
      await db.insert('workout_exercises', e);
    }
  }

  Future<void> _seedExercises(Database db) async {
    final defaultExercises = [
      Exercise(
        id: 'ex-1',
        name: 'Supino Reto com Barra',
        muscleGroup: 'Peito',
        equipment: 'Barra',
        instructions: 'Deite-se no banco com os olhos sob a barra. Segure com pegada ligeiramente mais larga que os ombros. Desça a barra controladamente até a linha dos mamilos e empurre até a extensão quase completa.',
        secondaryMuscles: ['Tríceps', 'Deltoide Anterior'],
      ),
      Exercise(
        id: 'ex-2',
        name: 'Supino Inclinado com Halteres',
        muscleGroup: 'Peito',
        equipment: 'Halteres',
        instructions: 'Ajuste o banco entre 30° e 45°. Mantenha as escápulas retraídas e desça os halteres alinhados ao peitoral superior.',
        secondaryMuscles: ['Deltoide Anterior', 'Tríceps'],
      ),
      Exercise(
        id: 'ex-3',
        name: 'Crucifixo na Polia (Crossover)',
        muscleGroup: 'Peito',
        equipment: 'Polia',
        instructions: 'Com polias médias/altas, dê um passo à frente e flexione levemente os cotovelos. Traga as mãos à frente cruzando ou tocando os polegares no pico de contração.',
        secondaryMuscles: ['Deltoide Anterior'],
      ),
      Exercise(
        id: 'ex-4',
        name: 'Puxada Aberta na Frente',
        muscleGroup: 'Costas',
        equipment: 'Máquina',
        instructions: 'Segure a barra com pegada pronada aberta. Puxe a barra em direção à parte superior do peito enquanto retrai e deprime as escápulas.',
        secondaryMuscles: ['Bíceps', 'Braquial', 'Trapézio'],
      ),
      Exercise(
        id: 'ex-5',
        name: 'Remada Curvada com Barra',
        muscleGroup: 'Costas',
        equipment: 'Barra',
        instructions: 'Tronco inclinado a 45°, coluna neutra e joelhos semi-flexionados. Puxe a barra em direção ao umbigo cotovelos apontando para trás.',
        secondaryMuscles: ['Lombar', 'Bíceps', 'Trapézio'],
      ),
      Exercise(
        id: 'ex-6',
        name: 'Agachamento Livre com Barra',
        muscleGroup: 'Pernas',
        equipment: 'Barra',
        instructions: 'Barra apoiada no trapézio, pés afastados na largura dos ombros. Flexione joelhos e quadril descendo até que a coxa fique paralela ao solo.',
        secondaryMuscles: ['Glúteos', 'Core', 'Posteriores de Coxa'],
      ),
      Exercise(
        id: 'ex-7',
        name: 'Leg Press 45°',
        muscleGroup: 'Pernas',
        equipment: 'Máquina',
        instructions: 'Pés na plataforma na largura do quadril. Desça controlando o peso sem deixar a lombar sair do encosto, estenda sem hiperextender os joelhos.',
        secondaryMuscles: ['Glúteos', 'Quadríceps'],
      ),
      Exercise(
        id: 'ex-8',
        name: 'Mesa Flexora',
        muscleGroup: 'Pernas',
        equipment: 'Máquina',
        instructions: 'Deitado de bruços, almofada logo acima do calcanhar. Flexione os joelhos puxando os pés em direção aos glúteos e controle a descida.',
        secondaryMuscles: ['Panturrilhas'],
      ),
      Exercise(
        id: 'ex-9',
        name: 'Desenvolvimento Militar com Halteres',
        muscleGroup: 'Ombros',
        equipment: 'Halteres',
        instructions: 'Sentado ou em pé com a coluna ereta. Eleve os halteres acima da cabeça até quase encostarem, descendo até a altura dos ouvidos.',
        secondaryMuscles: ['Tríceps', 'Peitoral Superior'],
      ),
      Exercise(
        id: 'ex-10',
        name: 'Elevação Lateral com Halteres',
        muscleGroup: 'Ombros',
        equipment: 'Halteres',
        instructions: 'Em pé, eleve os braços lateralmente até a altura dos ombros, mantendo ligeira flexão de cotovelo e sem usar impulsos do tronco.',
        secondaryMuscles: ['Trapézio'],
      ),
      Exercise(
        id: 'ex-11',
        name: 'Rosca Direta com Barra W',
        muscleGroup: 'Braços',
        equipment: 'Barra',
        instructions: 'Cotovelos firmes ao lado do tronco. Flexione os antebraços erguendo a barra com contração máxima nos bíceps e desça devagar.',
        secondaryMuscles: ['Braquial', 'Antebraços'],
      ),
      Exercise(
        id: 'ex-12',
        name: 'Tríceps Corda na Polia',
        muscleGroup: 'Braços',
        equipment: 'Polia',
        instructions: 'Fixe a corda na polia alta. Estenda os braços para baixo abrindo as pontas da corda ao final do movimento.',
        secondaryMuscles: ['Antebraços'],
      ),
      Exercise(
        id: 'ex-13',
        name: 'Prancha Isométrica',
        muscleGroup: 'Core',
        equipment: 'Peso do corpo',
        instructions: 'Apoie antebraços e pontas dos pés no chão. Mantenha o corpo em linha reta e abdômen contraído sem deixar o quadril cair.',
        secondaryMuscles: ['Lombar', 'Glúteos'],
      ),
    ];

    final batch = db.batch();
    for (final exercise in defaultExercises) {
      batch.insert('exercises', exercise.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
