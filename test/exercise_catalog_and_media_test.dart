import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymr/core/utils/exercise_images.dart';
import 'package:gymr/data/database/app_database.dart';
import 'package:gymr/data/repositories/exercise_repository.dart';
import 'package:gymr/domain/models/exercise.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExerciseImageHelper 100% Offline Asset Tests', () {
    test('ExerciseImageHelper resolves offline asset for exact name', () {
      final asset = ExerciseImageHelper.getExerciseAsset('Supino Reto com Barra');
      expect(asset, equals('assets/exercises/ex-1-supino-reto.png'));
    });

    test('ExerciseImageHelper resolves offline asset for case-insensitive and partial names', () {
      expect(
        ExerciseImageHelper.getExerciseAsset('supino reto'),
        equals('assets/exercises/ex-1-supino-reto.png'),
      );
      expect(
        ExerciseImageHelper.getExerciseAsset('Agachamento Livre com Barra'),
        equals('assets/exercises/ex-6-agachamento-livre.png'),
      );
      expect(
        ExerciseImageHelper.getExerciseAsset('agachamento'),
        equals('assets/exercises/ex-6-agachamento-livre.png'),
      );
      expect(
        ExerciseImageHelper.getExerciseAsset('Leg Press 45°'),
        equals('assets/exercises/ex-7-leg-press-45.png'),
      );
      expect(
        ExerciseImageHelper.getExerciseAsset('prancha isométrica'),
        equals('assets/exercises/ex-13-prancha-isometrica.png'),
      );
    });

    test('ExerciseImageHelper preserves valid local mediaUrl when provided', () {
      const customAsset = 'assets/exercises/ex-1-supino-reto.png';
      final asset = ExerciseImageHelper.getExerciseAsset('Exercício Customizado', mediaUrl: customAsset);
      expect(asset, equals(customAsset));
    });

    test('ExerciseImageHelper falls back to placeholder for unknown exercise', () {
      final asset = ExerciseImageHelper.getExerciseAsset('Exercício Misterioso Inexistente XYZ');
      expect(asset, equals(ExerciseImageHelper.placeholderAsset));
    });

    test('ExerciseImageHelper returns placeholder for empty or whitespace string', () {
      expect(ExerciseImageHelper.getExerciseAsset(''), equals(ExerciseImageHelper.placeholderAsset));
      expect(ExerciseImageHelper.getExerciseAsset('   '), equals(ExerciseImageHelper.placeholderAsset));
    });

    test('All general app artwork points to local offline assets', () {
      expect(ExerciseImageHelper.coachNarezAsset, startsWith('assets/images/'));
      expect(ExerciseImageHelper.todayWorkoutCoverAsset, startsWith('assets/images/'));
      expect(ExerciseImageHelper.athleteAvatarAsset, startsWith('assets/images/'));
      expect(ExerciseImageHelper.placeholderAsset, startsWith('assets/images/'));
    });

    testWidgets('ExerciseImageHelper.getExerciseImage builds an Image.asset widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExerciseImageHelper.getExerciseImage('Supino Reto com Barra'),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final Image imageWidget = tester.widget(imageFinder);
      expect(imageWidget.image, isA<AssetImage>());
      final AssetImage assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, equals('assets/exercises/ex-1-supino-reto.png'));
    });
  });

  group('Exercise Model Media Serialization Tests', () {
    test('Exercise serializes and deserializes mediaUrl properly', () {
      const exercise = Exercise(
        id: 'ex-test-1',
        name: 'Supino Reto',
        muscleGroup: 'Peito',
        equipment: 'Barra',
        instructions: 'Instruções de teste',
        secondaryMuscles: ['Tríceps'],
        mediaUrl: 'assets/exercises/ex-1-supino-reto.png',
        isCustom: false,
      );

      final map = exercise.toMap();
      expect(map['mediaUrl'], equals('assets/exercises/ex-1-supino-reto.png'));

      final restored = Exercise.fromMap(map);
      expect(restored.id, equals('ex-test-1'));
      expect(restored.name, equals('Supino Reto'));
      expect(restored.mediaUrl, equals('assets/exercises/ex-1-supino-reto.png'));
      expect(restored.secondaryMuscles, contains('Tríceps'));
    });
  });

  group('Physical Asset Bundling Verification', () {
    final expectedExercises = [
      'assets/exercises/ex-1-supino-reto.png',
      'assets/exercises/ex-2-supino-inclinado.png',
      'assets/exercises/ex-3-crucifixo-polia.png',
      'assets/exercises/ex-4-puxada-aberta.png',
      'assets/exercises/ex-5-remada-curvada.png',
      'assets/exercises/ex-6-agachamento-livre.png',
      'assets/exercises/ex-7-leg-press-45.png',
      'assets/exercises/ex-8-mesa-flexora.png',
      'assets/exercises/ex-9-desenvolvimento-militar.png',
      'assets/exercises/ex-10-elevacao-lateral.png',
      'assets/exercises/ex-11-rosca-direta.png',
      'assets/exercises/ex-12-triceps-corda.png',
      'assets/exercises/ex-13-prancha-isometrica.png',
    ];

    for (final path in expectedExercises) {
      test('Physical asset file exists and is non-empty: $path', () {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Arquivo $path deve existir fisicamente');
        expect(file.lengthSync(), greaterThan(100), reason: 'Arquivo $path não pode ser vazio');
      });
    }

    final generalImages = [
      'assets/images/coach_narez.png',
      'assets/images/athlete_avatar.png',
      'assets/images/workout_cover.png',
      'assets/images/exercise_placeholder.png',
    ];

    for (final path in generalImages) {
      test('General image file exists and is non-empty: $path', () {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Arquivo $path deve existir fisicamente');
        expect(file.lengthSync(), greaterThan(100), reason: 'Arquivo $path não pode ser vazio');
      });
    }
  });

  group('ExerciseRepository filterExercises Unit Tests', () {
    late FakeDatabase fakeDb;
    late ExerciseRepository repository;

    final sampleExercises = [
      {
        'id': 'ex-1',
        'name': 'Supino Reto com Barra',
        'muscleGroup': 'Peito',
        'equipment': 'Barra',
        'instructions': 'Deite-se no banco com os olhos sob a barra.',
        'secondaryMuscles': 'Tríceps, Deltoide Anterior',
        'mediaUrl': 'assets/exercises/ex-1-supino-reto.png',
        'isCustom': 0,
      },
      {
        'id': 'ex-2',
        'name': 'Supino Inclinado com Halteres',
        'muscleGroup': 'Peito',
        'equipment': 'Halteres',
        'instructions': 'Ajuste o banco entre 30° e 45°.',
        'secondaryMuscles': 'Deltoide Anterior, Tríceps',
        'mediaUrl': 'assets/exercises/ex-2-supino-inclinado.png',
        'isCustom': 0,
      },
      {
        'id': 'ex-3',
        'name': 'Crucifixo na Polia (Crossover)',
        'muscleGroup': 'Peito',
        'equipment': 'Polia',
        'instructions': 'Com polias médias/altas, cruze as mãos.',
        'secondaryMuscles': 'Deltoide Anterior',
        'mediaUrl': 'assets/exercises/ex-3-crucifixo-polia.png',
        'isCustom': 0,
      },
      {
        'id': 'ex-4',
        'name': 'Puxada Aberta na Frente',
        'muscleGroup': 'Costas',
        'equipment': 'Polia',
        'instructions': 'Puxe a barra até a altura da clavícula.',
        'secondaryMuscles': 'Bíceps, Deltoide Posterior',
        'mediaUrl': 'assets/exercises/ex-4-puxada-aberta.png',
        'isCustom': 0,
      },
      {
        'id': 'ex-6',
        'name': 'Agachamento Livre com Barra',
        'muscleGroup': 'Pernas',
        'equipment': 'Barra',
        'instructions': 'Agache mantendo a coluna alinhada.',
        'secondaryMuscles': 'Glúteos, Core',
        'mediaUrl': 'assets/exercises/ex-6-agachamento-livre.png',
        'isCustom': 0,
      },
      {
        'id': 'ex-9',
        'name': 'Desenvolvimento Militar com Halteres',
        'muscleGroup': 'Ombros',
        'equipment': 'Halteres',
        'instructions': 'Empurre os halteres para cima.',
        'secondaryMuscles': 'Tríceps',
        'mediaUrl': 'assets/exercises/ex-9-desenvolvimento-militar.png',
        'isCustom': 0,
      },
      {
        'id': 'ex-13',
        'name': 'Prancha Isométrica',
        'muscleGroup': 'Core',
        'equipment': 'Peso do corpo',
        'instructions': 'Mantenha o corpo alinhado e abdômen contraído.',
        'secondaryMuscles': 'Ombros, Glúteos',
        'mediaUrl': 'assets/exercises/ex-13-prancha-isometrica.png',
        'isCustom': 0,
      },
    ];

    setUp(() {
      fakeDb = FakeDatabase(sampleExercises);
      repository = ExerciseRepository(dbProvider: FakeAppDatabase(fakeDb));
    });

    test('Filter by muscle group (e.g. Peito) returns matching exercises', () async {
      final results = await repository.filterExercises(muscleGroup: 'Peito');
      expect(results.length, equals(3));
      expect(results.every((e) => e.muscleGroup == 'Peito'), isTrue);
      expect(fakeDb.lastWhere, equals('LOWER(muscleGroup) = LOWER(?)'));
      expect(fakeDb.lastWhereArgs, equals(['Peito']));
    });

    test('Filter by equipment (e.g. Halteres) returns matching exercises', () async {
      final results = await repository.filterExercises(equipment: 'Halteres');
      expect(results.length, equals(2));
      expect(results.map((e) => e.id), containsAll(['ex-2', 'ex-9']));
      expect(fakeDb.lastWhere, equals('LOWER(equipment) = LOWER(?)'));
      expect(fakeDb.lastWhereArgs, equals(['Halteres']));
    });

    test('Combined filter (muscle group + equipment + search query) narrows results', () async {
      final results = await repository.filterExercises(
        muscleGroup: 'Peito',
        equipment: 'Halteres',
        query: 'Inclinado',
      );
      expect(results.length, equals(1));
      expect(results.first.id, equals('ex-2'));
      expect(results.first.name, equals('Supino Inclinado com Halteres'));
      expect(fakeDb.lastWhere, contains('LOWER(muscleGroup) = LOWER(?)'));
      expect(fakeDb.lastWhere, contains('LOWER(equipment) = LOWER(?)'));
      expect(fakeDb.lastWhere, contains('LOWER(name) LIKE ?'));
    });

    test('Case insensitivity and whitespace trimming work on all filter dimensions', () async {
      final resultsMuscle = await repository.filterExercises(muscleGroup: '   peito   ');
      expect(resultsMuscle.length, equals(3));

      final resultsEquip = await repository.filterExercises(equipment: '   HALTERES   ');
      expect(resultsEquip.length, equals(2));

      final resultsQuery = await repository.filterExercises(query: '   sUpInO   ');
      expect(resultsQuery.length, equals(2));
      expect(fakeDb.lastWhereArgs, contains('%supino%'));
    });

    test('Special options Todos and ALL ignore filter clauses and return all items', () async {
      final resultsTodos = await repository.filterExercises(
        muscleGroup: 'Todos',
        equipment: 'Todos',
      );
      expect(resultsTodos.length, equals(sampleExercises.length));
      expect(fakeDb.lastWhere, isNull);

      final resultsAll = await repository.filterExercises(
        muscleGroup: 'all',
        equipment: 'ALL',
        query: '   ',
      );
      expect(resultsAll.length, equals(sampleExercises.length));
      expect(fakeDb.lastWhere, isNull);

      final resultsWhitespaceTodos = await repository.filterExercises(
        muscleGroup: '  Todos  ',
        equipment: '  all  ',
      );
      expect(resultsWhitespaceTodos.length, equals(sampleExercises.length));
      expect(fakeDb.lastWhere, isNull);
    });

    test('Non-matching queries return empty list cleanly without throwing', () async {
      final nonMatchingQuery = await repository.filterExercises(query: 'xyzInexistente123');
      expect(nonMatchingQuery, isEmpty);

      final conflictingFilters = await repository.filterExercises(
        muscleGroup: 'Costas',
        equipment: 'Halteres',
      );
      expect(conflictingFilters, isEmpty);
    });
  });
}

class FakeAppDatabase implements AppDatabase {
  final Database _database;

  FakeAppDatabase(this._database);

  @override
  Future<Database> get database async => _database;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDatabase implements Database {
  final List<Map<String, dynamic>> data;
  String? lastWhere;
  List<Object?>? lastWhereArgs;

  FakeDatabase(this.data);

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    lastWhere = where;
    lastWhereArgs = whereArgs;

    if (where == null) {
      final copy = List<Map<String, Object?>>.from(data);
      if (orderBy != null && orderBy.contains('name ASC')) {
        copy.sort((a, b) => (a['name'] as String? ?? '').compareTo(b['name'] as String? ?? ''));
      }
      return copy;
    }

    var filtered = List<Map<String, Object?>>.from(data);
    var argIndex = 0;

    if (where.contains('LOWER(muscleGroup) = LOWER(?)')) {
      final target = (whereArgs![argIndex++] as String).toLowerCase();
      filtered = filtered.where((item) {
        final val = (item['muscleGroup'] as String? ?? '').toLowerCase();
        return val == target;
      }).toList();
    }

    if (where.contains('LOWER(equipment) = LOWER(?)')) {
      final target = (whereArgs![argIndex++] as String).toLowerCase();
      filtered = filtered.where((item) {
        final val = (item['equipment'] as String? ?? '').toLowerCase();
        return val == target;
      }).toList();
    }

    if (where.contains('LOWER(name) LIKE ?')) {
      final rawPattern = (whereArgs![argIndex++] as String).toLowerCase();
      final pattern = rawPattern.replaceAll('%', '');
      argIndex += 4;

      filtered = filtered.where((item) {
        final name = (item['name'] as String? ?? '').toLowerCase();
        final muscle = (item['muscleGroup'] as String? ?? '').toLowerCase();
        final equip = (item['equipment'] as String? ?? '').toLowerCase();
        final instructions = (item['instructions'] as String? ?? '').toLowerCase();
        final secondary = (item['secondaryMuscles'] as String? ?? '').toLowerCase();
        return name.contains(pattern) ||
            muscle.contains(pattern) ||
            equip.contains(pattern) ||
            instructions.contains(pattern) ||
            secondary.contains(pattern);
      }).toList();
    }

    if (orderBy != null && orderBy.contains('name ASC')) {
      filtered.sort((a, b) => (a['name'] as String? ?? '').compareTo(b['name'] as String? ?? ''));
    }

    return filtered;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
