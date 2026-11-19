import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/exercise_images.dart';
import '../progress/workout_history_view.dart';
import '../widgets/app_notifications_sheet.dart';
import '../widgets/gymr_logo_title.dart';
import 'profile_view_model.dart';

class ProfileView extends StatefulWidget {
  final Function(String? workoutId)? onStartWorkout;
  final VoidCallback? onNavigateToWorkouts;
  final VoidCallback? onNavigateToProgress;

  const ProfileView({
    super.key,
    this.onStartWorkout,
    this.onNavigateToWorkouts,
    this.onNavigateToProgress,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfileData();
    });
  }

  void _showEditProfileDialog(BuildContext context, ProfileViewModel vm) {
    final nameController = TextEditingController(text: vm.userName);

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
            'Editar Perfil',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome do Atleta'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  vm.updateProfileName(nameController.text.trim());
                }
                Navigator.pop(context);
              },
              child: const Text('SALVAR'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateBiometricsDialog(BuildContext context, ProfileViewModel vm) {
    final weightController = TextEditingController(text: vm.currentWeightKg.toStringAsFixed(1));
    final heightController = TextEditingController(text: vm.heightM.toStringAsFixed(2));
    final bfController = TextEditingController(text: vm.bodyFatPercentage.toStringAsFixed(1));

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
            'Atualizar Biometria',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Altura (m, ex: 1.78)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bfController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: '% Gordura Corporal (BF)'),
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
                final w = double.tryParse(weightController.text) ?? vm.currentWeightKg;
                final h = double.tryParse(heightController.text) ?? vm.heightM;
                final bf = double.tryParse(bfController.text) ?? vm.bodyFatPercentage;

                vm.updateBiometrics(weight: w, height: h, bodyFat: bf);
                Navigator.pop(context);
              },
              child: const Text('ATUALIZAR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const GymrLogoTitle(title: 'Perfil'),
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
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNeon))
          : RefreshIndicator(
              color: AppColors.primaryNeon,
              backgroundColor: AppColors.surfaceCard,
              onRefresh: () => vm.loadProfileData(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // 1. Card Principal do Atleta (Design Stitch)
                  _buildProfileHeroCard(context, vm),
                  const SizedBox(height: 16),

                  // 2. Estatísticas Rápidas (Grid 3 colunas)
                  _buildQuickStatsGrid(vm),
                  const SizedBox(height: 24),

                  // 3. Seção Biometria & Metas
                  _buildBiometricsSection(context, vm),
                  const SizedBox(height: 24),

                  // 4. Seção Acesso Rápido & Rotinas (Atalhos do Atleta)
                  _buildQuickAccessSection(context, vm),
                  const SizedBox(height: 24),

                  // 5. Seção Conquistas & Recordes
                  _buildAchievementsSection(vm),
                  const SizedBox(height: 28),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeroCard(BuildContext context, ProfileViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF18191D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF26272B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar com aro neon e ponto de status ativo
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryNeon, width: 2),
                  color: const Color(0xFF22242A),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    ExerciseImageHelper.athleteAvatarAsset,
                    width: 62,
                    height: 62,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        vm.userName.isNotEmpty
                            ? vm.userName
                                .split(' ')
                                .map((e) => e.isNotEmpty ? e[0] : '')
                                .take(2)
                                .join()
                            : 'ML',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNeon,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF18191D), width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Informações do Atleta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${vm.athleteTier} • ${vm.userCode}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        vm.planTier,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textOnNeon,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Text(
                      'Membro Ativo',
                      style: TextStyle(
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

          // Botão Editar Perfil
          IconButton(
            onPressed: () => _showEditProfileDialog(context, vm),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF22242A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(ProfileViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.fitness_center_rounded,
            value: '${vm.totalSessionsCount}',
            label: 'TREINOS',
            valueColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            icon: Icons.insights_rounded,
            value: '${vm.totalVolumeTons.toStringAsFixed(1)}t',
            label: 'VOLUME',
            valueColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            icon: Icons.local_fire_department_rounded,
            value: '${vm.streakWeeks} sem',
            label: 'STREAK',
            valueColor: AppColors.primaryNeon,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF18191D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26272B)),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryNeon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, size: 16, color: AppColors.primaryNeon),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: valueColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricsSection(BuildContext context, ProfileViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'BIOMETRIA & METAS',
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
            GestureDetector(
              onTap: () => _showUpdateBiometricsDialog(context, vm),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, size: 14, color: AppColors.primaryNeon),
                  SizedBox(width: 3),
                  Text(
                    'Atualizar',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNeon,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF18191D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF26272B)),
          ),
          child: Row(
            children: [
              // Peso
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PESO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: vm.currentWeightKg.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const TextSpan(
                            text: ' kg',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vm.weightDeltaKg >= 0 ? '+' : ''}${vm.weightDeltaKg.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: vm.weightDeltaKg <= 0 ? AppColors.primaryNeon : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 42, color: Colors.white.withValues(alpha: 0.06)),
              const SizedBox(width: 14),

              // Altura / IMC
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ALTURA',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: vm.heightM.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const TextSpan(
                            text: ' m',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'IMC ${vm.bmi.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 42, color: Colors.white.withValues(alpha: 0.06)),
              const SizedBox(width: 14),

              // Gordura (BF)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GORDURA (BF)',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: vm.bodyFatPercentage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const TextSpan(
                            text: ' %',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vm.bodyFatDelta >= 0 ? '+' : ''}${vm.bodyFatDelta.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: vm.bodyFatDelta <= 0 ? AppColors.primaryNeon : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessSection(BuildContext context, ProfileViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Expanded(
              child: Text(
                'ACESSO RÁPIDO & ROTINAS',
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
              '3 atalhos',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Card 1: Treino de Hoje em Destaque
        InkWell(
          onTap: () => widget.onStartWorkout?.call(vm.todayWorkoutId),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF18191D), Color(0xFF1C1F24)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNeon.withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNeon,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.textOnNeon,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNeon.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'TREINO DE HOJE',
                                style: TextStyle(
                                  color: AppColors.primaryNeon,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            vm.todayWorkoutSession ?? 'Sessão B',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        vm.todayWorkoutName ?? 'Peito & Tríceps',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    Text(
                      'Iniciar',
                      style: TextStyle(
                        color: AppColors.primaryNeon,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, color: AppColors.primaryNeon, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Card 2: Minhas Fichas & Divisões
        InkWell(
          onTap: widget.onNavigateToWorkouts,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF18191D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF26272B)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22242A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primaryNeon,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Minhas Fichas & Divisões',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '3 ativas',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Divisão ABC: Push, Pull & Legs',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Card 3: Progressão & Carga
        InkWell(
          onTap: widget.onNavigateToProgress,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF18191D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF26272B)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22242A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: AppColors.primaryNeon,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Flexible(
                            child: Text(
                              'Progressão & Carga',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryNeon.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              vm.benchPressPR > 0
                                  ? '${vm.benchPressPR.toStringAsFixed(0)}kg PR'
                                  : '1RM & PRs',
                              style: const TextStyle(
                                color: AppColors.primaryNeon,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Análise de 1RM e volume acumulado',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(ProfileViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'CONQUISTAS & RECORDES',
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
                  MaterialPageRoute(
                    builder: (_) => const WorkoutHistoryView(initialTab: 1),
                  ),
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
        Row(
          children: [
            Expanded(
              child: _buildAchievementCard(
                title: 'Supino',
                value: '${vm.benchPressPR.toStringAsFixed(0)} kg',
                badgeText: 'RECORDE',
                isNeonBadge: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAchievementCard(
                title: 'Agachamento',
                value: '${vm.squatPR.toStringAsFixed(0)} kg',
                badgeText: '1RM MAX',
                isNeonBadge: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildAchievementCard(
                title: 'Frequência',
                value: '${vm.frequencyStreakWeeks} sem',
                badgeText: 'SEM FALHAR',
                isNeonBadge: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required String title,
    required String value,
    required String badgeText,
    required bool isNeonBadge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF18191D),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26272B)),
      ),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isNeonBadge ? AppColors.primaryNeon : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isNeonBadge
                  ? AppColors.primaryNeon.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: isNeonBadge ? AppColors.primaryNeon : AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
