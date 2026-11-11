import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../exercises/exercise_detail_view.dart';
import 'active_workout_view_model.dart';

class ActiveWorkoutView extends StatefulWidget {
  final String? workoutId;

  const ActiveWorkoutView({super.key, this.workoutId});

  @override
  State<ActiveWorkoutView> createState() => _ActiveWorkoutViewState();
}

class _ActiveWorkoutViewState extends State<ActiveWorkoutView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ActiveWorkoutViewModel>();
      if (!vm.isSessionActive) {
        vm.startWorkoutSession(widget.workoutId);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ActiveWorkoutView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.workoutId != null && widget.workoutId != oldWidget.workoutId) {
      context.read<ActiveWorkoutViewModel>().startWorkoutSession(widget.workoutId);
    }
  }

  void _confirmFinishWorkout(BuildContext context, ActiveWorkoutViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.primaryNeon),
              SizedBox(width: 10),
              Text('Finalizar Treino?', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          content: Text(
            'Você treinou por ${vm.formattedSessionDuration}. Deseja salvar o histórico e os cálculos de carga?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CONTINUAR', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final success = await vm.finishWorkout();
                if (success) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Treino concluído com sucesso! Salvo no histórico.'),
                      backgroundColor: AppColors.primaryNeon,
                    ),
                  );
                }
              },
              child: const Text('FINALIZAR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActiveWorkoutViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryNeon)),
      );
    }

    if (vm.exerciseItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Treino Ativo', style: TextStyle(fontWeight: FontWeight.w800))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center_outlined, size: 56, color: AppColors.textMuted),
                const SizedBox(height: 16),
                const Text(
                  'Nenhum exercício carregado',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crie ou selecione uma ficha na aba "Fichas" para iniciar a execução do treino.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => vm.startWorkoutSession(null),
                  child: const Text('RECARREGAR TREINO'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryNeon.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'GymR',
                style: TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Treino Ativo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        actions: [
          // Cronômetro de tempo total com luz pulsante
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryNeon,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primaryNeon, blurRadius: 6, spreadRadius: 1),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  vm.formattedSessionDuration,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Cabeçalho da rotina
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNeon.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          vm.workout?.split ?? 'Treino',
                          style: const TextStyle(
                            color: AppColors.primaryNeon,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${vm.exerciseItems.length} Exercícios',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vm.workout?.name ?? 'Sessão Livre',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Card de Descanso Inteligente (Timer Regressivo)
          if (vm.isRestActive) _buildRestCard(context, vm),

          const SizedBox(height: 14),

          // Lista de Exercícios e Séries
          ...List.generate(vm.exerciseItems.length, (exIndex) {
            final item = vm.exerciseItems[exIndex];
            return _buildExerciseCard(context, vm, exIndex, item);
          }),

          const SizedBox(height: 80), // Espaço para não cobrir com o botão de rodapé
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.surfaceBorder, width: 1)),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () => _confirmFinishWorkout(context, vm),
            icon: const Icon(Icons.task_alt, color: AppColors.textOnNeon, size: 22),
            label: const Text('CONCLUIR TREINO'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestCard(BuildContext context, ActiveWorkoutViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNeon.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.timer, color: AppColors.primaryNeon, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'INTERVALO DE DESCANSO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryNeon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'EM ANDAMENTO',
                  style: TextStyle(
                    color: AppColors.primaryNeon,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            vm.formattedRestRemaining,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              fontFamily: 'monospace',
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: vm.restProgress,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryNeon),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => vm.addRestSeconds(30),
                icon: const Icon(Icons.add, size: 16, color: AppColors.primaryNeon),
                label: const Text('+30s', style: TextStyle(color: AppColors.primaryNeon, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => vm.skipRest(),
                child: const Text('Pular Descanso', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    ActiveWorkoutViewModel vm,
    int exIndex,
    ActiveExerciseItem item,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryNeon,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${exIndex + 1}',
                      style: const TextStyle(
                        color: AppColors.textOnNeon,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.exercise.exerciseName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 18, color: AppColors.primaryNeon),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final ex = await vm.getExerciseDetails(item.exercise.exerciseId);
                      if (ex != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ExerciseDetailView(exercise: ex)),
                        );
                      }
                    },
                  ),
                ],
              ),
              Text(
                '${item.exercise.restSeconds}s descanso',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Tabela de Séries
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 36, child: Text('SÉRIE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary))),
                Expanded(child: Center(child: Text('CARGA (KG)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)))),
                Expanded(child: Center(child: Text('REPS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)))),
                SizedBox(width: 50, child: Center(child: Text('CHECK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)))),
              ],
            ),
          ),

          const SizedBox(height: 8),

          ...List.generate(item.sets.length, (setIndex) {
            final s = item.sets[setIndex];
            final isDone = s.isCompleted;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDone ? AppColors.primaryNeon.withValues(alpha: 0.08) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDone ? AppColors.primaryNeon.withValues(alpha: 0.3) : AppColors.surfaceBorder,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${s.setNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: isDone ? AppColors.primaryNeon : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        height: 38,
                        child: TextFormField(
                          initialValue: s.weightKg.toStringAsFixed(1),
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            fillColor: isDone ? Colors.transparent : AppColors.surfaceContainer,
                          ),
                          onChanged: (val) {
                            final parsed = double.tryParse(val);
                            if (parsed != null) vm.updateSetWeight(exIndex, setIndex, parsed);
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        height: 38,
                        child: TextFormField(
                          initialValue: s.reps.toString(),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            fillColor: isDone ? Colors.transparent : AppColors.surfaceContainer,
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null) vm.updateSetReps(exIndex, setIndex, parsed);
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Center(
                      child: InkWell(
                        onTap: () => vm.toggleSetCompleted(exIndex, setIndex),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.primaryNeon : AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDone ? AppColors.primaryNeon : AppColors.surfaceBorder,
                            ),
                            boxShadow: isDone
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryNeon.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            Icons.check,
                            color: isDone ? AppColors.textOnNeon : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 6),

          // Botões simplificados de adicionar/remover série extra
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (item.sets.length > 1)
                TextButton(
                  onPressed: () => vm.removeLastSet(exIndex),
                  child: const Text(
                    'Remover Série',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              TextButton.icon(
                onPressed: () => vm.addExtraSet(exIndex),
                icon: const Icon(Icons.add, size: 16, color: AppColors.primaryNeon),
                label: const Text(
                  'Adicionar Série',
                  style: TextStyle(color: AppColors.primaryNeon, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
