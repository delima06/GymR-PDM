import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout.dart';
import '../widgets/gymr_logo_title.dart';
import '../exercises/exercise_catalog_view.dart';

class CreateWorkoutView extends StatefulWidget {
  final Workout? workoutToEdit;

  const CreateWorkoutView({super.key, this.workoutToEdit});

  /// Valida se a faixa de repetições é válida (minReps >= 1 e minReps <= maxReps)
  static bool isValidRepRange(int minReps, int maxReps) {
    return minReps >= 1 && minReps <= maxReps;
  }

  /// Valida se a quantidade de séries é válida (targetSets >= 1)
  static bool isValidTargetSets(int targetSets) {
    return targetSets >= 1;
  }

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
    final selectedExercise = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (_) => const ExerciseCatalogView(isSelectionMode: true),
      ),
    );
    if (selectedExercise != null && mounted) {
      _configureExerciseDetails(exercise: selectedExercise);
    }
  }

  Future<void> _configureExerciseDetails({
    Exercise? exercise,
    WorkoutExercise? existingExercise,
    int? editingIndex,
  }) async {
    assert(exercise != null || existingExercise != null);
    final isEditing = existingExercise != null && editingIndex != null;
    final exerciseName = existingExercise?.exerciseName ?? exercise!.name;
    final exerciseId = existingExercise?.exerciseId ?? exercise!.id;

    final result = await showDialog<WorkoutExercise>(
      context: context,
      builder: (_) => _ExerciseConfigDialog(
        exerciseName: exerciseName,
        exerciseId: exerciseId,
        existingExercise: existingExercise,
        orderIndex: isEditing ? existingExercise.orderIndex : _exercises.length,
        isEditing: isEditing,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (isEditing) {
          _exercises[editingIndex] = result;
        } else {
          _exercises.add(result);
        }
      });
    }
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

    for (final e in _exercises) {
      if (!CreateWorkoutView.isValidTargetSets(e.targetSets)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No exercício "${e.exerciseName}", número de séries deve ser no mínimo 1!'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      if (!CreateWorkoutView.isValidRepRange(e.minReps, e.maxReps)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No exercício "${e.exerciseName}", repetições mínimas não podem ser menores que 1 ou maiores que as máximas!'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
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
                const Expanded(
                  child: Text(
                    'Exercícios Selecionados',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
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
                          child: InkWell(
                            onTap: () {
                              _configureExerciseDetails(
                                existingExercise: item,
                                editingIndex: index,
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.exerciseName,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                                      ),
                                    ),
                                    const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryNeon),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.targetSets} séries • ${item.repRangeText} reps • ${item.initialWeight} kg • ${item.restSeconds}s descanso',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
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

class _ExerciseConfigDialog extends StatefulWidget {
  final String exerciseName;
  final String exerciseId;
  final WorkoutExercise? existingExercise;
  final int orderIndex;
  final bool isEditing;

  const _ExerciseConfigDialog({
    required this.exerciseName,
    required this.exerciseId,
    this.existingExercise,
    required this.orderIndex,
    required this.isEditing,
  });

  @override
  State<_ExerciseConfigDialog> createState() => _ExerciseConfigDialogState();
}

class _ExerciseConfigDialogState extends State<_ExerciseConfigDialog> {
  late final TextEditingController setsController;
  late final TextEditingController minRepsController;
  late final TextEditingController maxRepsController;
  late final TextEditingController weightController;
  late final TextEditingController restController;

  @override
  void initState() {
    super.initState();
    final ex = widget.existingExercise;
    setsController = TextEditingController(text: (ex?.targetSets ?? 3).toString());
    minRepsController = TextEditingController(text: (ex?.minReps ?? 8).toString());
    maxRepsController = TextEditingController(text: (ex?.maxReps ?? 12).toString());
    weightController = TextEditingController(text: (ex?.initialWeight ?? 20.0).toStringAsFixed(1));
    restController = TextEditingController(text: (ex?.restSeconds ?? 60).toString());
  }

  @override
  void dispose() {
    setsController.dispose();
    minRepsController.dispose();
    maxRepsController.dispose();
    weightController.dispose();
    restController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
      title: Text(
        widget.isEditing ? 'Editar ${widget.exerciseName}' : widget.exerciseName,
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
            final parsedSets = int.tryParse(setsController.text) ?? 3;
            final parsedMinReps = int.tryParse(minRepsController.text) ?? 8;
            final parsedMaxReps = int.tryParse(maxRepsController.text) ?? 12;

            if (!CreateWorkoutView.isValidTargetSets(parsedSets)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Número de séries deve ser no mínimo 1!'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            if (!CreateWorkoutView.isValidRepRange(parsedMinReps, parsedMaxReps)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Repetições mínimas não podem ser menores que 1 ou maiores que as máximas!'),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            final configured = WorkoutExercise(
              id: widget.isEditing ? widget.existingExercise!.id : const Uuid().v4(),
              workoutId: widget.isEditing ? widget.existingExercise!.workoutId : '',
              exerciseId: widget.exerciseId,
              exerciseName: widget.exerciseName,
              targetSets: parsedSets,
              minReps: parsedMinReps,
              maxReps: parsedMaxReps,
              initialWeight: double.tryParse(weightController.text) ?? 0.0,
              restSeconds: int.tryParse(restController.text) ?? 60,
              orderIndex: widget.orderIndex,
            );

            Navigator.pop(context, configured);
          },
          child: Text(widget.isEditing ? 'SALVAR' : 'ADICIONAR'),
        ),
      ],
    );
  }
}
