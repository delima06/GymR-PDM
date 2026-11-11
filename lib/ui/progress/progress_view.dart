import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import 'progress_view_model.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  int _selectedTab = 0; // 0: Cargas & 1RM, 1: Histórico, 2: Medidas
  final List<String> _tabs = ['Cargas & 1RM', 'Histórico', 'Medidas'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().loadProgressData();
    });
  }

  void _showAddMeasurementDialog(BuildContext context, ProgressViewModel vm) {
    final weightController = TextEditingController();
    final bodyFatController = TextEditingController();
    final armsController = TextEditingController();
    final waistController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          title: const Text(
            'Nova Medição Corporal',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Peso Atual (kg)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyFatController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: '% Gordura Corporal (opcional)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: armsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Circunferência Braço (cm)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: waistController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Circunferência Cintura (cm)'),
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
                final weight = double.tryParse(weightController.text);
                final bf = double.tryParse(bodyFatController.text);
                final arms = double.tryParse(armsController.text);
                final waist = double.tryParse(waistController.text);

                vm.addMeasurement(
                  weightKg: weight,
                  bodyFatPercentage: bf,
                  armsCm: arms,
                  waistCm: waist,
                );
                Navigator.pop(context);
              },
              child: const Text('SALVAR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico e Evolução', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryNeon,
        backgroundColor: AppColors.surfaceCard,
        onRefresh: () => vm.loadProgressData(),
        child: Column(
          children: [
            // Filtros em pílulas (Pills)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedTab == index;
                  return Center(
                    child: ChoiceChip(
                      label: Text(_tabs[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedTab = index);
                      },
                      selectedColor: AppColors.primaryNeon,
                      backgroundColor: AppColors.surfaceElevated,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.textOnNeon : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isSelected ? AppColors.primaryNeon : AppColors.surfaceBorder),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
                  : _buildSelectedTabContent(context, vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(BuildContext context, ProgressViewModel vm) {
    switch (_selectedTab) {
      case 0:
        return _buildPRsAnd1RMTab(context, vm);
      case 1:
        return _buildHistoryTab(context, vm);
      case 2:
        return _buildMeasurementsTab(context, vm);
      default:
        return const SizedBox();
    }
  }

  // Aba 1: Cargas & 1RM
  Widget _buildPRsAnd1RMTab(BuildContext context, ProgressViewModel vm) {
    if (vm.prs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center_outlined, size: 50, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text(
                'Nenhum recorde registrado ainda',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Conclua seu primeiro treino no "Modo Treino Ativo" para calcular automaticamente seu 1RM e progressões.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Card Fórmula de Epley (Didático e transparente)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.functions, size: 20, color: AppColors.primaryNeon),
                  SizedBox(width: 8),
                  Text(
                    'Fórmula de Epley (Estimativa de 1RM)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                '1RM = Carga × (1 + Repetições / 30). Quando você atinge 12 reps na carga máxima, o app sugere progressão automática!',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ...vm.prs.map((pr) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: pr.shouldProgressWeight
                    ? AppColors.primaryNeon.withValues(alpha: 0.5)
                    : AppColors.surfaceBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pr.exerciseName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '1RM: ${pr.estimated1RM.toStringAsFixed(1)} kg',
                        style: const TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Recorde Pessoal (PR): ${pr.maxWeightKg.toStringAsFixed(1)} kg para ${pr.maxRepsAtMaxWeight} repetições',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                if (pr.shouldProgressWeight) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNeon.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_upward, size: 16, color: AppColors.primaryNeon),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Sugestão: Aumentar +2.5 kg no próximo treino!',
                            style: TextStyle(
                              color: AppColors.primaryNeon,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // Aba 2: Histórico de Treinos
  Widget _buildHistoryTab(BuildContext context, ProgressViewModel vm) {
    if (vm.sessions.isEmpty) {
      return const Center(
        child: Text('Nenhum treino concluído ainda.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: vm.sessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final session = vm.sessions[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryNeon.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.primaryNeon, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.workoutName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormatter.format(session.startTime),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${session.totalVolumeKg.toStringAsFixed(0)} kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppColors.primaryNeon,
                    ),
                  ),
                  Text(
                    'Tempo: ${session.formattedDuration}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Aba 3: Medidas Corporais
  Widget _buildMeasurementsTab(BuildContext context, ProgressViewModel vm) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddMeasurementDialog(context, vm),
              icon: const Icon(Icons.add, color: AppColors.textOnNeon, size: 20),
              label: const Text('REGISTRAR NOVA MEDIÇÃO'),
            ),
          ),
        ),
        Expanded(
          child: vm.measurements.isEmpty
              ? const Center(
                  child: Text('Nenhuma medição registrada ainda.', style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: vm.measurements.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final m = vm.measurements[index];
                    final dateStr = DateFormat('dd/MM/yyyy').format(m.date);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              if (m.weightKg != null)
                                Text(
                                  '${m.weightKg!.toStringAsFixed(1)} kg',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: AppColors.primaryNeon,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              if (m.bodyFatPercentage != null)
                                Text('Gordura: ${m.bodyFatPercentage}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              if (m.armsCm != null)
                                Text('Braço: ${m.armsCm} cm', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              if (m.waistCm != null)
                                Text('Cintura: ${m.waistCm} cm', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
