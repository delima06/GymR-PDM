import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'workouts_view_model.dart';
import 'create_workout_view.dart';

class WorkoutsView extends StatefulWidget {
  final Function(String workoutId)? onStartWorkoutById;

  const WorkoutsView({super.key, this.onStartWorkoutById});

  @override
  State<WorkoutsView> createState() => _WorkoutsViewState();
}

class _WorkoutsViewState extends State<WorkoutsView> {
  final List<String> _filters = ['Todos', 'ABC', 'Upper/Lower', 'Full Body'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutsViewModel>().loadWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WorkoutsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Fichas',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryNeon,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: AppColors.textOnNeon, size: 20),
            ),
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const CreateWorkoutView()),
              );
              if (created == true && mounted) {
                viewModel.loadWorkouts();
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Filtros por Divisão (Split)
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = viewModel.selectedFilter == filter;
                return Center(
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => viewModel.setFilter(filter),
                    backgroundColor: AppColors.surfaceElevated,
                    selectedColor: AppColors.primaryNeon,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.textOnNeon : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryNeon : AppColors.surfaceBorder,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Lista de Fichas
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
                : viewModel.filteredWorkouts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.note_alt_outlined, size: 54, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'Nenhuma ficha encontrada',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Clique no botão "+" acima para montar sua ficha.',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: viewModel.filteredWorkouts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final workout = viewModel.filteredWorkouts[index];
                          return _buildWorkoutCard(context, workout, viewModel);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, dynamic workout, WorkoutsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryNeon.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  workout.split,
                  style: const TextStyle(
                    color: AppColors.primaryNeon,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                color: AppColors.surfaceElevated,
                onSelected: (value) {
                  if (value == 'delete') {
                    vm.deleteWorkout(workout.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Excluir Ficha', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            workout.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (workout.description != null && workout.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              workout.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '${workout.exercises.length} exercícios programados',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => widget.onStartWorkoutById?.call(workout.id),
              icon: const Icon(Icons.play_arrow_rounded, color: AppColors.textOnNeon, size: 20),
              label: const Text('INICIAR ESTE TREINO'),
            ),
          ),
        ],
      ),
    );
  }
}
