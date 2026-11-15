import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/exercise_images.dart';
import '../../domain/models/exercise.dart';
import '../widgets/gymr_logo_title.dart';

class ExerciseDetailView extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailView({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GymrLogoTitle(title: exercise.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner Ilustrado / Visual do Exercício (toque para ampliar)
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: AppColors.surfaceCard,
                  insetPadding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppColors.surfaceBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 3.0,
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: ExerciseImageHelper.getExerciseImage(
                              exercise.name,
                              mediaUrl: exercise.mediaUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              height: 190,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExerciseImageHelper.getExerciseImage(
                    exercise.name,
                    mediaUrl: exercise.mediaUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNeon.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          size: 34,
                          color: AppColors.primaryNeon,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        exercise.muscleGroup.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryNeon,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 12,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_out_map_rounded, size: 13, color: AppColors.primaryNeon),
                          SizedBox(width: 4),
                          Text(
                            'Ampliar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tags de Categoria e Equipamento
          Row(
            children: [
              _buildTag(Icons.category_outlined, exercise.muscleGroup),
              const SizedBox(width: 8),
              _buildTag(Icons.handyman_outlined, exercise.equipment),
            ],
          ),

          const SizedBox(height: 20),

          // Músculos Trabalhados
          const Text(
            'Músculos Trabalhados',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryNeon.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${exercise.muscleGroup} (Principal)',
                  style: const TextStyle(color: AppColors.primaryNeon, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              ...exercise.secondaryMuscles.map(
                (m) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Text(
                    m,
                    style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Instruções Técnicas Passo a Passo
          const Text(
            'Instruções Técnicas de Execução',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.primaryNeon, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    exercise.instructions.isNotEmpty
                        ? exercise.instructions
                        : 'Mantenha a postura correta, coluna ereta e realize o movimento de forma controlada.',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
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

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryNeon),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

