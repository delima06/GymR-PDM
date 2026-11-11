import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/exercise.dart';

class ExerciseDetailView extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailView({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner Ilustrado / Visual do Exercício
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        size: 48,
                        color: AppColors.primaryNeon,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      exercise.muscleGroup.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
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

