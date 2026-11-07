import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'dashboard/dashboard_view.dart';
import 'workouts/workouts_view.dart';
import 'active_workout/active_workout_view.dart';
import 'progress/progress_view.dart';

class MainNavigationScaffold extends StatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _currentIndex = 0;
  String? _selectedWorkoutIdForActive;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _startWorkout([String? workoutId]) {
    setState(() {
      _selectedWorkoutIdForActive = workoutId;
      _currentIndex = 2; // Índice da aba 'Treino Ativo'
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardView(
        onStartWorkout: () => _startWorkout(),
        onNavigateToWorkouts: () => _onTabTapped(1),
      ),
      WorkoutsView(
        onStartWorkoutById: (id) => _startWorkout(id),
      ),
      ActiveWorkoutView(
        workoutId: _selectedWorkoutIdForActive,
      ),
      const ProgressView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.surfaceBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: AppColors.surfaceCard,
          selectedItemColor: AppColors.primaryNeon,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Fichas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: 'Treino Ativo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_rounded),
              activeIcon: Icon(Icons.insights_rounded),
              label: 'Evolução',
            ),
          ],
        ),
      ),
    );
  }
}
