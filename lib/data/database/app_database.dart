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
      version: 1,
      onCreate: _createDB,
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

    // Seed inicial com catálogo padrão
    await _seedExercises(db);
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
