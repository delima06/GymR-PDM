import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout.dart';
import '../widgets/gymr_logo_title.dart';
import '../exercises/exercise_detail_view.dart';

class CreateWorkoutView extends StatefulWidget {
  final Workout? workoutToEdit;

  const CreateWorkoutView({super.key, this.workoutToEdit});

  @override
  State<CreateWorkoutView> createState() => _CreateWorkoutViewState();
}

class _CreateWorkoutViewState extends State<CreateWorkoutView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedSplit = 'ABC';

  final List<WorkoutExercise> _exercises = [];
  final _workoutRepository = WorkoutRepository();
  final _exerciseRepository = ExerciseRepository();

  bool _isSaving = false;

  final List<String> _splitOptions = ['ABC', 'Upper/Lower', 'Full Body', 'Push/Pull/Legs', 'Personalizado'];

  @override
  void initState() {
    super.initState();
    if (widget.workoutToEdit != null) {
      final w = widget.workoutToEdit!;
      _nameController.text = w.name;
      _descriptionController.text = w.description ?? '';
      _selectedSplit = _splitOptions.contains(w.split) ? w.split : 'Personalizado';
      _exercises.addAll(w.exercises);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addExerciseToWorkout() async {
    final exercises = await _exerciseRepository.getAllExercises();
    if (!mounted) return;

    showModalBottomSheet<Exercise>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Selecione um Exercício',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ex = exercises[index];
                      return ListTile(
                        tileColor: AppColors.surfaceCard,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.surfaceBorder),
                        ),
                        title: Text(
                          ex.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${ex.muscleGroup} • ${ex.equipment}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ExerciseDetailView(exercise: ex)),
                                );
                              },
                            ),
                            const Icon(Icons.add_circle_outline, color: AppColors.primaryNeon),
                          ],
                        ),
                        onTap: () => Navigator.pop(context, ex),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((selectedExercise) {
      if (selectedExercise != null) {
        _configureExerciseDetails(selectedExercise);
      }
    });
  }

  void _configureExerciseDetails(Exercise exercise) {
    int sets = 3;
    int minReps = 8;
    int maxReps = 12;
    double weight = 20.0;
    int rest = 60;

    final setsController = TextEditingController(text: sets.toString());
    final minRepsController = TextEditingController(text: minReps.toString());
    final maxRepsController = TextEditingController(text: maxReps.toString());
    final weightController = TextEditingController(text: weight.toStringAsFixed(1));
    final restController = TextEditingController(text: rest.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          title: Text(
            exercise.name,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: setsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Número de Séries'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minRepsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Reps Mínimas'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: maxRepsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Reps Máximas'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Carga Inicial (kg)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: restController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Descanso (segundos)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final configured = WorkoutExercise(
                  id: const Uuid().v4(),
                  workoutId: '',
                  exerciseId: exercise.id,
                  exerciseName: exercise.name,
                  targetSets: int.tryParse(setsController.text) ?? 3,
                  minReps: int.tryParse(minRepsController.text) ?? 8,
                  maxReps: int.tryParse(maxRepsController.text) ?? 12,
                  initialWeight: double.tryParse(weightController.text) ?? 0.0,
                  restSeconds: int.tryParse(restController.text) ?? 60,
                  orderIndex: _exercises.length,
                );
                setState(() {
                  _exercises.add(configured);
                });
                Navigator.pop(context);
              },
              child: const Text('ADICIONAR'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um exercício na ficha!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final workoutId = widget.workoutToEdit?.id ?? const Uuid().v4();
    final exercisesWithWorkoutId = _exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final e = entry.value;
      return WorkoutExercise(
        id: e.id.isNotEmpty ? e.id : const Uuid().v4(),
        workoutId: workoutId,
        exerciseId: e.exerciseId,
        exerciseName: e.exerciseName,
        targetSets: e.targetSets,
        minReps: e.minReps,
        maxReps: e.maxReps,
        initialWeight: e.initialWeight,
        restSeconds: e.restSeconds,
        orderIndex: index,
      );
    }).toList();

    final workout = Workout(
      id: workoutId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      split: _selectedSplit,
      exercises: exercisesWithWorkoutId,
      createdAt: widget.workoutToEdit?.createdAt ?? DateTime.now(),
    );

    try {
      await _workoutRepository.saveWorkout(workout);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar ficha: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GymrLogoTitle(title: widget.workoutToEdit != null ? 'Editar Ficha' : 'Nova Ficha'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveWorkout,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryNeon),
                  )
                : const Text(
                    'SALVAR',
                    style: TextStyle(
                      color: AppColors.primaryNeon,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Treino (ex: Treino A - Peito e Tríceps)',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome do treino';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição ou Foco (opcional)',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Divisão de Treino (Split)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _splitOptions.map((split) {
                final isSelected = _selectedSplit == split;
                return ChoiceChip(
                  label: Text(split),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedSplit = split);
                  },
                  selectedColor: AppColors.primaryNeon,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.textOnNeon : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercícios Selecionados',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                TextButton.icon(
                  onPressed: _addExerciseToWorkout,
                  icon: const Icon(Icons.add, size: 18, color: AppColors.primaryNeon),
                  label: const Text('Adicionar', style: TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_exercises.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.fitness_center, size: 36, color: AppColors.textMuted),
                    const SizedBox(height: 8),
                    const Text(
                      'Nenhum exercício adicionado ainda.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _addExerciseToWorkout,
                      icon: const Icon(Icons.playlist_add, color: AppColors.primaryNeon),
                      label: const Text('Abrir Catálogo de Exercícios', style: TextStyle(color: AppColors.primaryNeon)),
                    ),
                  ],
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _exercises.removeAt(oldIndex);
                    _exercises.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final item = _exercises[index];
                  return Container(
                    key: ValueKey(item.id),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.drag_indicator, color: AppColors.textMuted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.exerciseName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.targetSets} séries • ${item.repRangeText} reps • ${item.initialWeight} kg • ${item.restSeconds}s descanso',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                          onPressed: () {
                            setState(() {
                              _exercises.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
