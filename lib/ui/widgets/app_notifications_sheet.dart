import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/workout_repository.dart';

class AppNotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String tag;
  final bool isHighlight;

  const AppNotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.tag,
    this.isHighlight = false,
  });
}

class AppNotificationsSheet extends StatefulWidget {
  const AppNotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF18191D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AppNotificationsSheet(),
    );
  }

  @override
  State<AppNotificationsSheet> createState() => _AppNotificationsSheetState();
}

class _AppNotificationsSheetState extends State<AppNotificationsSheet> {
  final _historyRepository = HistoryRepository();
  final _workoutRepository = WorkoutRepository();

  bool _isLoading = true;
  List<AppNotificationItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadRealNotifications();
  }

  Future<void> _loadRealNotifications() async {
    final List<AppNotificationItem> notifications = [];
    try {
      final prs = await _historyRepository.getExercisePRs();
      for (final pr in prs.where((p) => p.shouldProgressWeight)) {
        notifications.add(
          AppNotificationItem(
            icon: Icons.trending_up_rounded,
            title: 'Hora de Progredir Carga',
            message:
                '${pr.exerciseName}: você atingiu ${pr.maxRepsAtMaxWeight} reps com ${pr.maxWeightKg.toStringAsFixed(1)} kg. Sugestão: ${pr.suggestedNextWeightKg.toStringAsFixed(1)} kg.',
            tag: '1RM / PR',
            isHighlight: true,
          ),
        );
      }

      final workouts = await _workoutRepository.getAllWorkouts();
      if (workouts.isNotEmpty) {
        final next = workouts.first;
        notifications.add(
          AppNotificationItem(
            icon: Icons.fitness_center_rounded,
            title: 'Ficha Disponível para Treino',
            message: '${next.name} (${next.exercises.length} exercícios programados).',
            tag: next.split.isNotEmpty ? next.split : 'TREINO',
          ),
        );
      }

      final measurements = await _historyRepository.getMeasurements();
      if (measurements.isEmpty) {
        notifications.add(
          const AppNotificationItem(
            icon: Icons.straighten_rounded,
            title: 'Avaliação Antropométrica Pendente',
            message: 'Registre suas medidas iniciais na aba Evolução para acompanhar seu progresso.',
            tag: 'MEDIDAS',
          ),
        );
      } else {
        final daysSinceLast = DateTime.now().difference(measurements.first.date).inDays;
        if (daysSinceLast >= 7) {
          notifications.add(
            AppNotificationItem(
              icon: Icons.straighten_rounded,
              title: 'Check-in de Medidas',
              message: 'Faz $daysSinceLast dias desde seu último registro antropométrico.',
              tag: 'MEDIDAS',
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar notificações do app: $e');
    } finally {
      if (mounted) {
        setState(() {
          _items = notifications;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notificações do App',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  if (!_isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNeon.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_items.length}',
                        style: const TextStyle(
                          color: AppColors.primaryNeon,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryNeon),
                  ),
                )
              else if (_items.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121316),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.notifications_off_outlined, color: AppColors.textSecondary, size: 32),
                      SizedBox(height: 8),
                      Text(
                        'Nenhuma notificação no momento',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Seus alertas de progressão de carga e treinos aparecerão aqui.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121316),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: item.isHighlight
                                ? AppColors.primaryNeon.withValues(alpha: 0.35)
                                : Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNeon.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item.icon, color: AppColors.primaryNeon, size: 20),
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
                                          item.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.06),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.tag,
                                          style: const TextStyle(
                                            color: AppColors.primaryNeon,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.message,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
