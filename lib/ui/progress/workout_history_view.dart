import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/history_repository.dart';
import '../widgets/gymr_logo_title.dart';
import 'progress_view_model.dart';

/// Tela completa de Histórico de Treinos, Recordes (PRs) e Medidas Corporais.
class WorkoutHistoryView extends StatefulWidget {
  final int initialTab;

  const WorkoutHistoryView({super.key, this.initialTab = 0});

  @override
  State<WorkoutHistoryView> createState() => _WorkoutHistoryViewState();
}

class _WorkoutHistoryViewState extends State<WorkoutHistoryView> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy • HH:mm');
  final DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().loadProgressData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();

    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTab.clamp(0, 2),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const GymrLogoTitle(title: 'Histórico Completo'),
          bottom: TabBar(
            indicatorColor: AppColors.primaryNeon,
            labelColor: AppColors.primaryNeon,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            tabs: [
              Tab(text: 'Treinos (${vm.sessions.length})'),
              Tab(text: 'Recordes (${vm.prs.length})'),
              Tab(text: 'Medidas (${vm.measurements.length})'),
            ],
          ),
        ),
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
            : TabBarView(
                children: [
                  _buildSessionsTab(vm.sessions),
                  _buildPRsTab(vm.prs),
                  _buildMeasurementsTab(vm.measurements),
                ],
              ),
      ),
    );
  }

  Widget _buildSessionsTab(List<WorkoutSessionRecord> sessions) {
    if (sessions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: 'Nenhuma sessão concluída',
        subtitle: 'Finalize um treino ativo para registrar suas sessões aqui.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final s = sessions[index];
        return _HistoryCard(
          icon: Icons.check_circle_outline_rounded,
          title: s.workoutName,
          subtitle: '${_dateFormat.format(s.startTime)} • Volume: ${s.totalVolumeKg.toStringAsFixed(0)} kg',
          badge: s.formattedDuration,
          isNeon: index == 0,
        );
      },
    );
  }

  Widget _buildPRsTab(List<ExercisePRRecord> prs) {
    if (prs.isEmpty) {
      return _buildEmptyState(
        icon: Icons.workspace_premium_outlined,
        title: 'Nenhum recorde registrado',
        subtitle: 'Registre séries com carga e repetições para calcular seu 1RM.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: prs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final pr = prs[index];
        final subtitle = pr.shouldProgressWeight
            ? '${pr.maxWeightKg.toStringAsFixed(1)} kg × ${pr.maxRepsAtMaxWeight} reps • 1RM: ${pr.estimated1RM.toStringAsFixed(1)} kg • Próx: ${pr.suggestedNextWeightKg.toStringAsFixed(1)} kg'
            : '${pr.maxWeightKg.toStringAsFixed(1)} kg × ${pr.maxRepsAtMaxWeight} reps • 1RM: ${pr.estimated1RM.toStringAsFixed(1)} kg';
        return _HistoryCard(
          icon: Icons.workspace_premium_outlined,
          title: pr.exerciseName,
          subtitle: subtitle,
          badge: pr.shouldProgressWeight ? '+2.5 kg' : 'PR',
          isNeon: pr.shouldProgressWeight,
        );
      },
    );
  }

  Widget _buildMeasurementsTab(List<MeasurementRecord> measurements) {
    if (measurements.isEmpty) {
      return _buildEmptyState(
        icon: Icons.straighten_rounded,
        title: 'Nenhuma medida registrada',
        subtitle: 'Adicione sua avaliação corporal para acompanhar a evolução.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: measurements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final m = measurements[index];
        final parts = <String>[
          if (m.weightKg != null) 'Peso: ${m.weightKg!.toStringAsFixed(1)} kg',
          if (m.bodyFatPercentage != null) 'BF: ${m.bodyFatPercentage!.toStringAsFixed(1)}%',
          if (m.armsCm != null) 'Braço: ${m.armsCm!.toStringAsFixed(1)} cm',
          if (m.waistCm != null) 'Cintura: ${m.waistCm!.toStringAsFixed(1)} cm',
          if (m.chestCm != null) 'Tórax: ${m.chestCm!.toStringAsFixed(1)} cm',
          if (m.thighsCm != null) 'Coxas: ${m.thighsCm!.toStringAsFixed(1)} cm',
          if (m.calvesCm != null) 'Panturrilha: ${m.calvesCm!.toStringAsFixed(1)} cm',
        ];
        return _HistoryCard(
          icon: Icons.monitor_weight_outlined,
          title: _shortDateFormat.format(m.date),
          subtitle: parts.isNotEmpty ? parts.join(' • ') : 'Registro fotográfico',
          badge: m.photoPaths.isNotEmpty ? '${m.photoPaths.length} foto(s)' : 'MEDIDA',
          isNeon: index == 0,
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final bool isNeon;

  const _HistoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.isNeon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryNeon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryNeon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isNeon
                  ? AppColors.primaryNeon.withValues(alpha: 0.14)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isNeon
                    ? AppColors.primaryNeon.withValues(alpha: 0.35)
                    : AppColors.surfaceBorder,
              ),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: isNeon ? AppColors.primaryNeon : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
