import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ActiveWorkoutView extends StatelessWidget {
  final String? workoutId;

  const ActiveWorkoutView({super.key, this.workoutId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Treino Ativo', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryNeon.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryNeon.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(Icons.timer_outlined, size: 64, color: AppColors.primaryNeon),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pronto para o Treino?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecione uma de suas fichas na aba "Fichas" ou inicie um treino rápido para cronometrar séries e descanso.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
