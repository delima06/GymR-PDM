import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/history_repository.dart';
import '../widgets/gymr_logo_title.dart';
import 'comparative_photo_view.dart';
import 'progress_view_model.dart';
import 'register_measurement_view.dart';
import 'workout_history_view.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  int _selectedFilterIndex = 0;
  final List<Map<String, dynamic>> _filters = [
    {'name': 'Cargas', 'icon': Icons.fitness_center_rounded},
    {'name': 'Medidas', 'icon': Icons.straighten_rounded},
    {'name': 'Volume Total', 'icon': Icons.insights_rounded},
    {'name': '1RM Estimado', 'icon': Icons.star_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressViewModel>().loadProgressData();
    });
  }

  void _showAddMeasurementDialog(BuildContext context, ProgressViewModel vm) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const RegisterMeasurementView()),
    );
  }

  void _showExercisePicker(BuildContext context, ProgressViewModel vm) {
    final exercises = <String>{
      ...vm.prs.map((p) => p.exerciseName),
      'Supino Reto com Barra',
      'Agachamento Livre com Barra',
      'Levantamento Terra',
      'Desenvolvimento Militar',
    }.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF18191D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selecione o Exercício para Evolução',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(exercises.length, (i) {
                    final name = exercises[i];
                    final isSelected = name == vm.selectedExerciseName;
                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: isSelected ? const Color(0xFF22242A) : null,
                      leading: Icon(
                        Icons.fitness_center_rounded,
                        color: isSelected ? AppColors.primaryNeon : AppColors.textSecondary,
                        size: 20,
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryNeon : Colors.white,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded, color: AppColors.primaryNeon, size: 20)
                          : null,
                      onTap: () {
                        vm.selectExerciseForChart(name);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProgressViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const GymrLogoTitle(title: 'Histórico e Evolução'),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
          : RefreshIndicator(
              color: AppColors.primaryNeon,
              backgroundColor: AppColors.surfaceCard,
              onRefresh: () => vm.loadProgressData(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // 1. Filtros Horizontais em Pílula (Stitch)
                  _buildPillFilters(),
                  const SizedBox(height: 18),

                  // 2. Card de Destaque Superior Neon (Progresso Geral)
                  if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2) ...[
                    _buildNeonHighlightCard(),
                    const SizedBox(height: 22),
                  ],

                  // 3. Seção Evolução de Carga com Dropdown & Gráfico Neon
                  if (_selectedFilterIndex == 0 || _selectedFilterIndex == 3) ...[
                    _buildLoadEvolutionSection(context, vm),
                    const SizedBox(height: 24),
                  ],

                  // 4. Seção Medidas Corporais (Cards + Botão Registrar)
                  if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) ...[
                    _buildBodyMeasurementsSection(context, vm),
                    const SizedBox(height: 24),
                  ],

                  // 5. Seção Histórico Recente
                  _buildRecentHistorySection(vm),
                  const SizedBox(height: 18),

                  // 6. Card Consistência Mensal
                  if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2) ...[
                    _buildMonthlyConsistencyCard(vm),
                    const SizedBox(height: 28),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildPillFilters() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          final item = _filters[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryNeon : const Color(0xFF1C1D22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryNeon : Colors.white.withValues(alpha: 0.08),
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
                  Icon(
                    item['icon'] as IconData,
                    size: 15,
                    color: isSelected ? const Color(0xFF121316) : AppColors.primaryNeon,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item['name'] as String,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF121316) : AppColors.textSecondary,
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
    );
  }

  Widget _buildNeonHighlightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryNeon,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNeon.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DESTAQUE MENSAL',
                  style: TextStyle(
                    color: const Color(0xFF0D140E).withValues(alpha: 0.75),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Progresso Geral',
                  style: TextStyle(
                    color: Color(0xFF0D140E),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sua evolução de força está 14% acima do mês passado com alta consistência.',
                  style: TextStyle(
                    color: Color(0xFF0D140E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: 0.92,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: const Color(0xFF0D140E).withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D140E)),
                ),
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '92%',
                    style: TextStyle(
                      color: Color(0xFF0D140E),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Text(
                    'META',
                    style: TextStyle(
                      color: Color(0xFF0D140E),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadEvolutionSection(BuildContext context, ProgressViewModel vm) {
    final matchingPR = vm.prs.where((p) =>
        p.exerciseName.toLowerCase().contains(vm.selectedExerciseName.toLowerCase()));
    final gainText = matchingPR.isNotEmpty
        ? '+${(matchingPR.first.maxWeightKg * 0.15).toInt()} kg'
        : '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EVOLUÇÃO DE CARGA',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF18191D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF26272B)),
          ),
          child: Column(
            children: [
              // Dropdown & Ganho Badge
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showExercisePicker(context, vm),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22242A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.fitness_center_rounded, color: AppColors.primaryNeon, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vm.selectedExerciseName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNeon.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, color: AppColors.primaryNeon, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          gainText,
                          style: const TextStyle(
                            color: AppColors.primaryNeon,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Gráfico Neon com CustomPaint
              SizedBox(
                height: 140,
                width: double.infinity,
                child: CustomPaint(
                  painter: _NeonChartPainter(loadPoints: vm.selectedExercisePoints),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBodyMeasurementsSection(BuildContext context, ProgressViewModel vm) {
    final latestWeight = vm.latestWeight;
    final latestArms = vm.latestArms;
    final latestWaist = vm.latestWaist;
    final latestThighs = vm.latestThighs;
    final latestCalves = vm.latestCalves;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'MEDIDAS CORPORAIS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Histórico Real',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Card 1: Peso Corporal
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF18191D),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF26272B)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.monitor_weight_outlined, color: AppColors.primaryNeon, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PESO CORPORAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: latestWeight != null ? latestWeight.toStringAsFixed(1) : '--',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const TextSpan(
                                text: ' kg',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (vm.deltaWeight != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNeon.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        vm.deltaWeight! <= 0
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: AppColors.primaryNeon,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${vm.deltaWeight! >= 0 ? '+' : ''}${vm.deltaWeight!.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          color: AppColors.primaryNeon,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Grid Duplo: Braço & Cintura
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18191D),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF26272B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'BRAÇO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNeon.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.straighten_rounded, color: AppColors.primaryNeon, size: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: latestArms != null ? latestArms.toStringAsFixed(1) : '--',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const TextSpan(
                            text: ' cm',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (vm.deltaArms != null)
                      Row(
                        children: [
                          Icon(
                            vm.deltaArms! >= 0
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            color: AppColors.primaryNeon,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${vm.deltaArms! >= 0 ? '+' : ''}${vm.deltaArms!.toStringAsFixed(1)} cm',
                            style: const TextStyle(
                              color: AppColors.primaryNeon,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18191D),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF26272B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'CINTURA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNeon.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.circle_outlined, color: AppColors.primaryNeon, size: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: latestWaist != null ? latestWaist.toStringAsFixed(1) : '--',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const TextSpan(
                            text: ' cm',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (vm.deltaWaist != null)
                      Row(
                        children: [
                          Icon(
                            vm.deltaWaist! <= 0
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: AppColors.primaryNeon,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${vm.deltaWaist! >= 0 ? '+' : ''}${vm.deltaWaist!.toStringAsFixed(1)} cm',
                            style: const TextStyle(
                              color: AppColors.primaryNeon,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Grid Duplo: Coxas & Panturrilhas
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18191D),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF26272B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'COXAS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNeon.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.straighten_rounded, color: AppColors.primaryNeon, size: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: latestThighs != null ? latestThighs.toStringAsFixed(1) : '--',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const TextSpan(
                            text: ' cm',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (vm.deltaThighs != null)
                      Text(
                        '${vm.deltaThighs! >= 0 ? '+' : ''}${vm.deltaThighs!.toStringAsFixed(1)} cm',
                        style: const TextStyle(
                          color: AppColors.primaryNeon,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF18191D),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF26272B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'PANTURRILHAS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNeon.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.circle_outlined, color: AppColors.primaryNeon, size: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: latestCalves != null ? latestCalves.toStringAsFixed(1) : '--',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const TextSpan(
                            text: ' cm',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (vm.deltaCalves != null)
                      Text(
                        '${vm.deltaCalves! >= 0 ? '+' : ''}${vm.deltaCalves!.toStringAsFixed(1)} cm',
                        style: const TextStyle(
                          color: AppColors.primaryNeon,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Acesso à Galeria Fotográfica de Evolução (Antes vs Depois)
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ComparativePhotoView()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF18191D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNeon.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.compare_rounded,
                    color: AppColors.primaryNeon,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Galeria Fotográfica de Evolução',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Comparar fotos Antes vs Depois',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botão Primário Neon: Registrar Medidas
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => _showAddMeasurementDialog(context, vm),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNeon,
              foregroundColor: AppColors.textOnNeon,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primaryNeon.withValues(alpha: 0.3),
            ),
            icon: const Icon(Icons.add, color: AppColors.textOnNeon, size: 20),
            label: const Text(
              'REGISTRAR MEDIDAS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentHistorySection(ProgressViewModel vm) {
    final recentSession = vm.sessions.isNotEmpty ? vm.sessions.first : null;
    final topPr = vm.prs.isNotEmpty ? vm.prs.first : null;
    final latestM = vm.measurements.isNotEmpty ? vm.measurements.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'HISTÓRICO RECENTE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutHistoryView()),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryNeon,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (latestM != null)
          _buildHistoryItem(
            icon: Icons.monitor_weight_outlined,
            title: 'Registro de Medidas',
            dateText: 'Recente',
            subtitle: 'Peso: ${latestM.weightKg != null ? "${latestM.weightKg!.toStringAsFixed(1)} kg" : "--"} • Braço: ${latestM.armsCm != null ? "${latestM.armsCm!.toStringAsFixed(1)} cm" : "--"}',
            badgeText: 'CONCLUÍDO',
            isNeonBadge: true,
          ),
        const SizedBox(height: 8),

        if (topPr != null)
          _buildHistoryItem(
            icon: Icons.workspace_premium_outlined,
            title: 'Recorde (PR): ${topPr.exerciseName}',
            dateText: 'Recorde',
            subtitle: topPr.shouldProgressWeight
                ? '${topPr.maxWeightKg.toInt()} kg × ${topPr.maxRepsAtMaxWeight} • 1RM: ${topPr.estimated1RM.toInt()} kg • Próx: ${topPr.suggestedNextWeightKg.toStringAsFixed(1)} kg'
                : '${topPr.maxWeightKg.toInt()} kg × ${topPr.maxRepsAtMaxWeight} reps • 1RM: ${topPr.estimated1RM.toInt()} kg',
            badgeText: topPr.shouldProgressWeight ? '+2.5 kg' : 'RECORD',
            isNeonBadge: true,
          )
        else
          _buildHistoryItem(
            icon: Icons.workspace_premium_outlined,
            title: 'Sem Recorde Registrado',
            dateText: '--',
            subtitle: 'Complete séries no treino ativo para registrar PRs',
            badgeText: 'STANDBY',
            isNeonBadge: false,
          ),
        const SizedBox(height: 8),

        if (recentSession != null)
          _buildHistoryItem(
            icon: Icons.check_circle_outline_rounded,
            title: recentSession.workoutName,
            dateText: recentSession.formattedDuration,
            subtitle: 'Volume total: ${recentSession.totalVolumeKg.toInt()} kg',
            badgeText: 'FINALIZADO',
            isNeonBadge: false,
          )
        else
          _buildHistoryItem(
            icon: Icons.check_circle_outline_rounded,
            title: 'Nenhum Treino Realizado',
            dateText: '--',
            subtitle: 'Inicie e complete um treino para visualizar o histórico',
            badgeText: 'STANDBY',
            isNeonBadge: false,
          ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required String title,
    required String dateText,
    required String subtitle,
    required String badgeText,
    required bool isNeonBadge,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF18191D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26272B)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryNeon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: AppColors.primaryNeon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dateText,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isNeonBadge
                  ? AppColors.primaryNeon.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isNeonBadge
                    ? AppColors.primaryNeon.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: isNeonBadge ? AppColors.primaryNeon : Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyConsistencyCard(ProgressViewModel vm) {
    final completed = vm.sessions.length;
    const target = 20;
    final ratio = (completed / target).clamp(0.0, 1.0);
    final percent = (ratio * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18191D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26272B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  CircleAvatar(radius: 3, backgroundColor: AppColors.primaryNeon),
                  SizedBox(width: 6),
                  Text(
                    'CONSISTÊNCIA MENSAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Text(
                '$completed / $target treinos',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryNeon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: const Color(0xFF22242A),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryNeon),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percent% concluído',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  completed >= target
                      ? 'Meta mensal atingida!'
                      : 'Faltam ${target - completed} treinos para bater a meta',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NeonChartPainter extends CustomPainter {
  final List<ExerciseLoadPoint> loadPoints;

  _NeonChartPainter({this.loadPoints = const []});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF26272B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Linhas horizontais tracejadas
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.2), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.55), Offset(size.width, size.height * 0.55), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.9), Offset(size.width, size.height * 0.9), gridPaint);

    final List<Offset> points = [];
    final List<String> labels = [];

    if (loadPoints.length >= 2) {
      final minWeight = loadPoints.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
      final maxWeight = loadPoints.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
      final weightRange = (maxWeight - minWeight).clamp(10.0, 100.0);

      for (int i = 0; i < loadPoints.length; i++) {
        final p = loadPoints[i];
        final dx = size.width * (0.08 + (0.84 * (i / (loadPoints.length - 1))));
        final normalizedWeight = (p.weightKg - (minWeight - 5.0)) / (weightRange + 10.0);
        final dy = size.height * (0.88 - (0.72 * normalizedWeight.clamp(0.0, 1.0)));
        points.add(Offset(dx, dy));
        labels.add('${p.weightKg.toInt()}kg');
      }
    } else if (loadPoints.length == 1) {
      final p = loadPoints.first;
      points.add(Offset(size.width * 0.5, size.height * 0.5));
      labels.add('${p.weightKg.toInt()}kg');
    } else {
      // Zero mock data (Pilar I): se não houver registros, exibe empty state limpo
      final textSpan = TextSpan(
        text: 'Nenhum registro de carga ainda\nComplete um treino com este exercício',
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width - 40);

      textPainter.paint(
        canvas,
        Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
      );
      return;
    }

    if (points.length >= 2) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        path.quadraticBezierTo(p0.dx, p0.dy, controlPoint.dx, controlPoint.dy);
      }
      path.lineTo(points.last.dx, points.last.dy);

      // Gradiente abaixo da curva
      final fillPath = Path.from(path)
        ..lineTo(points.last.dx, size.height * 0.96)
        ..lineTo(points.first.dx, size.height * 0.96)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.primaryNeon.withValues(alpha: 0.35),
            AppColors.primaryNeon.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);

      // Linha neon principal
      final linePaint = Paint()
        ..color = AppColors.primaryNeon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, linePaint);
    }

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isLast = i == points.length - 1;

      // Círculo
      final circlePaint = Paint()
        ..color = isLast ? AppColors.primaryNeon : const Color(0xFF18191D)
        ..style = PaintingStyle.fill;

      final strokeCirclePaint = Paint()
        ..color = AppColors.primaryNeon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(pt, isLast ? 6 : 5, circlePaint);
      if (!isLast) {
        canvas.drawCircle(pt, 5, strokeCirclePaint);
      }

      // Label de texto
      final textSpan = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: isLast ? AppColors.primaryNeon : AppColors.textSecondary,
          fontSize: isLast ? 11 : 9.5,
          fontWeight: isLast ? FontWeight.w900 : FontWeight.w700,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(pt.dx - (textPainter.width / 2), isLast ? pt.dy - 18 : pt.dy + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NeonChartPainter oldDelegate) {
    return oldDelegate.loadPoints != loadPoints;
  }
}
