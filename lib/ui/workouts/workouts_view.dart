import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/exercise_images.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout.dart';
import '../widgets/gymr_logo_title.dart';
import 'workouts_view_model.dart';
import 'create_workout_view.dart';
import '../exercises/exercise_detail_view.dart';

class WorkoutsView extends StatefulWidget {
  final Function(String workoutId)? onStartWorkoutById;

  const WorkoutsView({super.key, this.onStartWorkoutById});

  @override
  State<WorkoutsView> createState() => _WorkoutsViewState();
}

class _WorkoutsViewState extends State<WorkoutsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutsViewModel>().loadWorkouts();
    });
  }

  void _navigateToCreateWorkout(BuildContext context, WorkoutsViewModel vm) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateWorkoutView()),
    );
    if (created == true && mounted) {
      vm.loadWorkouts();
    }
  }

  void _navigateToEditWorkout(BuildContext context, WorkoutsViewModel vm, Workout workout) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CreateWorkoutView(workoutToEdit: workout)),
    );
    if (updated == true && mounted) {
      vm.loadWorkouts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorkoutsViewModel>();
    final currentWorkout = viewModel.selectedWorkout;

    return Scaffold(
      appBar: AppBar(
        title: const GymrLogoTitle(title: 'Minhas Fichas'),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18191D),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNeon,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0B0C0E), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
          : viewModel.workouts.isEmpty
              ? _buildEmptyState(context, viewModel)
              : RefreshIndicator(
                  color: AppColors.primaryNeon,
                  backgroundColor: AppColors.surfaceCard,
                  onRefresh: () => viewModel.loadWorkouts(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    children: [
                      // 1. Seletor de Divisões em Pílulas (Stitch Design)
                      _buildDivisionSelector(context, viewModel),
                      const SizedBox(height: 16),

                      // 2. Card de Cabeçalho da Divisão Ativa
                      if (currentWorkout != null) ...[
                        _buildActiveWorkoutHeaderCard(context, currentWorkout, viewModel),
                        const SizedBox(height: 20),

                        // 3. Cabeçalho de Exercícios Cadastrados
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'EXERCÍCIOS CADASTRADOS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              '${currentWorkout.exercises.length} no total',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // 4. Lista de Exercícios com Ícones, Séries e Reps
                        if (currentWorkout.exercises.isEmpty)
                          _buildNoExercisesInWorkout(context, viewModel)
                        else
                          ...List.generate(currentWorkout.exercises.length, (index) {
                            final exercise = currentWorkout.exercises[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildExerciseCard(context, exercise, index + 1, viewModel),
                            );
                          }),

                        const SizedBox(height: 6),

                        // 5. Botão Tracejado: Adicionar Exercício
                        InkWell(
                          onTap: () => _navigateToEditWorkout(context, viewModel, currentWorkout),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF18191D),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.primaryNeon.withValues(alpha: 0.4),
                                style: BorderStyle.solid,
                                width: 1.2,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline_rounded,
                                    size: 18, color: AppColors.primaryNeon),
                                SizedBox(width: 8),
                                Text(
                                  'Adicionar Exercício',
                                  style: TextStyle(
                                    color: AppColors.primaryNeon,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 6. Botão de Ação Primário: Iniciar Este Treino
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => widget.onStartWorkoutById?.call(currentWorkout.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNeon,
                              foregroundColor: AppColors.textOnNeon,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6,
                              shadowColor: AppColors.primaryNeon.withValues(alpha: 0.4),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded,
                                color: AppColors.textOnNeon, size: 24),
                            label: const Text(
                              'INICIAR ESTE TREINO',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.8),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDivisionSelector(BuildContext context, WorkoutsViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'DIVISÕES DE TREINO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '${vm.workouts.length} divisões',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryNeon,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: vm.workouts.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              // Último item é o botão "+ Criar Treino"
              if (index == vm.workouts.length) {
                return InkWell(
                  onTap: () => _navigateToCreateWorkout(context, vm),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF18191D),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.35)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: AppColors.primaryNeon),
                        SizedBox(width: 4),
                        Text(
                          'Criar Treino',
                          style: TextStyle(
                            color: AppColors.primaryNeon,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final workout = vm.workouts[index];
              final isSelected = vm.selectedWorkoutIndex == index;

              return InkWell(
                onTap: () => vm.selectWorkout(index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryNeon : const Color(0xFF18191D),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryNeon : Colors.white.withValues(alpha: 0.06),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryNeon.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(
                          Icons.fitness_center_rounded,
                          size: 13,
                          color: AppColors.textOnNeon,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        workout.split.isNotEmpty ? workout.split : 'Treino ${index + 1}',
                        style: TextStyle(
                          color: isSelected ? AppColors.textOnNeon : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveWorkoutHeaderCard(
      BuildContext context, Workout workout, WorkoutsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF18191D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: AppColors.primaryNeon,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'FICHA ATIVA',
                            style: TextStyle(
                              color: AppColors.primaryNeon,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${workout.exercises.length} exercícios',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  workout.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: -0.3,
                  ),
                ),
                if (workout.description != null && workout.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    workout.description!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF202228),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.more_vert, size: 16, color: AppColors.textSecondary),
            ),
            color: AppColors.surfaceElevated,
            onSelected: (value) {
              if (value == 'edit') {
                _navigateToEditWorkout(context, vm, workout);
              } else if (value == 'delete') {
                vm.deleteWorkout(workout.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text('Editar Ficha', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Excluir Ficha', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    WorkoutExercise exercise,
    int index,
    WorkoutsViewModel vm,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExerciseDetailView(
              exercise: Exercise(
                id: exercise.exerciseId,
                name: exercise.exerciseName,
                muscleGroup: 'Musculação',
                equipment: 'Equipamento',
                instructions:
                    'Execute com cadência controlada e amplitude completa mantendo a postura firme.',
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF18191D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            // Thumbnail com Imagem Real do Stitch e Badge Numérico no topo
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF202228),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.network(
                      ExerciseImageHelper.getExerciseImageUrl(exercise.exerciseName) ?? '',
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.fitness_center_rounded,
                            color: AppColors.primaryNeon, size: 22),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -4,
                  left: -4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNeon,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Color(0xFF04210D),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Informações do Exercício
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '${exercise.targetSets} séries',
                        style: const TextStyle(
                          color: Color(0xFFE3E2E6),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text('•', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(width: 5),
                      Text(
                        '${exercise.minReps}-${exercise.maxReps} reps',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text('•', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(width: 5),
                      Text(
                        '${exercise.restSeconds}s desc.',
                        style: const TextStyle(
                          color: AppColors.primaryNeon,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu de opções do exercício
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
              color: AppColors.surfaceElevated,
              onSelected: (value) {
                if (value == 'remove') {
                  vm.removeExerciseFromSelectedWorkout(exercise.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Remover da Ficha', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoExercisesInWorkout(BuildContext context, WorkoutsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF18191D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center_outlined, size: 36, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          const Text(
            'Nenhum exercício nesta ficha',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Toque abaixo para incluir exercícios programados.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WorkoutsViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_alt_outlined, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 14),
            const Text(
              'Nenhuma ficha encontrada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Crie sua primeira divisão de treino (ex: ABC) para começar a acompanhar seus exercícios.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateWorkout(context, vm),
              icon: const Icon(Icons.add, color: AppColors.textOnNeon),
              label: const Text('CRIAR PRIMEIRA FICHA'),
            ),
          ],
        ),
      ),
    );
  }
}
