import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/exercise_images.dart';
import '../../domain/models/workout.dart';
import '../widgets/app_notifications_sheet.dart';
import '../widgets/gymr_logo_title.dart';
import 'dashboard_view_model.dart';

class DashboardView extends StatefulWidget {
  final void Function([String? workoutId])? onStartWorkout;
  final VoidCallback? onNavigateToWorkouts;

  const DashboardView({
    super.key,
    this.onStartWorkout,
    this.onNavigateToWorkouts,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedCategoryIndex = 0;
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Força', 'icon': Icons.fitness_center_rounded},
    {'name': 'Perda de Gordura', 'icon': Icons.local_fire_department_rounded},
    {'name': 'Cárdio', 'icon': Icons.bolt_rounded},
    {'name': 'Alongamento', 'icon': Icons.accessibility_new_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboardData();
    });
  }

  void _showTrainerFeedbackDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141519),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xFF22242A),
                          child: Icon(Icons.person, color: AppColors.primaryNeon, size: 24),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.primaryNeon,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF141519), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Coach Narez',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'PRO',
                              style: TextStyle(
                                color: AppColors.primaryNeon,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Preparador Físico & Biomecânica',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1B1F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: const Text(
                    '“Excelente cadência na última sessão! No Supino Inclinado, certifique-se de manter as escápulas aduzidas e os cotovelos alinhados a 45° do tronco para proteger a articulação glenoumeral e isolar a porção clavicular. Mantenha essa consistência!”',
                    style: TextStyle(
                      color: Color(0xFFF1F2F4),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ENTENDIDO, VALEU!'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const GymrLogoTitle(title: 'Início'),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
            onPressed: () => AppNotificationsSheet.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
          : RefreshIndicator(
              color: AppColors.primaryNeon,
              backgroundColor: AppColors.surfaceCard,
              onRefresh: () => viewModel.loadDashboardData(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // 1. Pílulas de Categoria com Ícones
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedCategoryIndex == index;
                        final item = _categories[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryNeon
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryNeon
                                    : AppColors.surfaceBorder,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryNeon.withValues(alpha: 0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  size: 16,
                                  color: isSelected
                                      ? AppColors.textOnNeon
                                      : AppColors.primaryNeon,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item['name'] as String,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.textOnNeon
                                        : AppColors.textSecondary,
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

                  const SizedBox(height: 18),

                  // 2. Hero Progress Card (Health Grade do Stitch)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10D85E), Color(0xFF00DE64), Color(0xFF00BD53)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryNeon.withValues(alpha: 0.32),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 3,
                                      backgroundColor: AppColors.textOnNeon,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'HEALTH GRADE',
                                      style: TextStyle(
                                        color: AppColors.textOnNeon,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Excelente Progresso!',
                                style: TextStyle(
                                  color: AppColors.textOnNeon,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                viewModel.completedSessionsCount > 0
                                    ? 'Você concluiu ${viewModel.completedSessionsCount} de 5 treinos da meta semanal (${((viewModel.completedSessionsCount / 5) * 100).clamp(0, 100).toInt()}%).'
                                    : 'Inicie seu primeiro treino para registrar volume e constância.',
                                style: TextStyle(
                                  color: AppColors.textOnNeon.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 68,
                              height: 68,
                              child: CircularProgressIndicator(
                                value: viewModel.completedSessionsCount > 0
                                    ? (viewModel.completedSessionsCount / 5).clamp(0.0, 1.0)
                                    : 0.0,
                                strokeWidth: 7,
                                strokeCap: StrokeCap.round,
                                backgroundColor: Colors.black.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.textOnNeon),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  viewModel.completedSessionsCount > 0
                                      ? '${((viewModel.completedSessionsCount / 5) * 100).clamp(0, 100).toInt()}%'
                                      : '0%',
                                  style: const TextStyle(
                                    color: AppColors.textOnNeon,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  viewModel.completedSessionsCount > 0 ? 'Nível A' : 'Nível 0',
                                  style: TextStyle(
                                    color: AppColors.textOnNeon.withValues(alpha: 0.75),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Métrica Rápida: Tempo Ativo (Stitch w-full)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141519),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryNeon.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
                                ),
                                child: const Icon(
                                  Icons.speed_rounded,
                                  color: AppColors.primaryNeon,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'TEMPO ATIVO',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        viewModel.formattedActiveTime,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1B1F),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(
                                  radius: 3,
                                  backgroundColor: AppColors.primaryNeon,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Meta semanal ${((viewModel.completedSessionsCount / 5) * 100).clamp(0, 100).toInt()}%',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Bloco Personal / Treinador (Coach Narez PRO)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141519),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primaryNeon.withValues(alpha: 0.4),
                                    width: 1.5),
                                color: const Color(0xFF22242A),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.asset(
                                  ExerciseImageHelper.coachNarezAsset,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.sports_gymnastics_rounded,
                                        color: AppColors.primaryNeon, size: 22),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryNeon,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF141519), width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Flexible(
                                    child: Text(
                                      'Coach Narez',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryNeon.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'PRO',
                                      style: TextStyle(
                                        color: AppColors.primaryNeon,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Novo feedback de postura enviado',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _showTrainerFeedbackDialog(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primaryNeon,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryNeon.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.chat_bubble_rounded,
                              color: AppColors.textOnNeon,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. Bloco Treino do Dia (Today's Workout)
                  if (viewModel.nextWorkout != null)
                    _buildTodayWorkoutCard(viewModel.nextWorkout!)
                  else
                    _buildEmptyWorkoutPrompt(),

                  const SizedBox(height: 16),

                  // 6. Foco Biomecânico de Hoje (Design Stitch)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141519),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.biotech_rounded, color: AppColors.primaryNeon, size: 18),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'FOCO BIOMECÂNICO DE HOJE',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNeon.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Hipertrofia',
                                style: TextStyle(
                                  color: AppColors.primaryNeon,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildMuscleChip('Peitoral Maior'),
                            _buildMuscleChip('Porção Clavicular'),
                            _buildMuscleChip('Tríceps Braquial'),
                            _buildMuscleChip('Deltoide Anterior'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildMuscleChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFF1F2F4),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTodayWorkoutCard(Workout workout) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF141519),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Imagem de fundo lateral direita com transparência e fade, exatamente como no Stitch
          Positioned(
            right: -10,
            top: 0,
            bottom: 0,
            width: 170,
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                ExerciseImageHelper.todayWorkoutCoverAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fitness_center_rounded, color: AppColors.primaryNeon, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'TREINO DO DIA',
                            style: TextStyle(
                              color: AppColors.primaryNeon,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1B1F),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: const Text(
                        'Intermediário',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Hoje: ${workout.name}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Builder(
                  builder: (context) {
                    final totalSets = workout.exercises.fold<int>(0, (sum, e) => sum + e.targetSets);
                    final totalEstimatedSeconds = workout.exercises.fold<int>(
                      0,
                      (sum, e) => sum + (e.targetSets * (45 + e.restSeconds)),
                    );
                    final estMinutes = (totalEstimatedSeconds / 60).round();

                    return Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, size: 14, color: AppColors.primaryNeon),
                            const SizedBox(width: 4),
                            Text(
                              estMinutes > 0 ? '$estMinutes min' : '-- min',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fitness_center_rounded, size: 14, color: AppColors.primaryNeon),
                            const SizedBox(width: 4),
                            Text(
                              '$totalSets séries',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        const Text('•', style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          '${workout.exercises.length} exercícios',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onStartWorkout?.call(workout.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNeon,
                      foregroundColor: AppColors.textOnNeon,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      shadowColor: AppColors.primaryNeon.withValues(alpha: 0.4),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, color: AppColors.textOnNeon, size: 24),
                    label: const Text(
                      'INICIAR TREINO',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkoutPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141519),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          const Icon(Icons.fitness_center_outlined, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma ficha criada ainda',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Monte sua primeira divisão de treino para começar a acompanhar suas cargas e volume.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: widget.onNavigateToWorkouts,
            icon: const Icon(Icons.add, color: AppColors.textOnNeon),
            label: const Text('CRIAR PRIMEIRA FICHA'),
          ),
        ],
      ),
    );
  }
}
