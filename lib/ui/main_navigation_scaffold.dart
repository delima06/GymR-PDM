import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/stitch_bottom_nav_bar.dart';
import 'dashboard/dashboard_view.dart';
import 'workouts/workouts_view.dart';
import 'active_workout/active_workout_view.dart';
import 'active_workout/active_workout_view_model.dart';
import 'progress/progress_view.dart';
import 'profile/profile_view.dart';

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
      _currentIndex = 2; // Aba central Treinar/Treino Ativo
    });
    context.read<ActiveWorkoutViewModel>().startWorkoutSession(workoutId);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardView(
        onStartWorkout: ([id]) => _startWorkout(id),
        onNavigateToWorkouts: () => _onTabTapped(1),
      ),
      WorkoutsView(
        onStartWorkoutById: (id) => _startWorkout(id),
      ),
      ActiveWorkoutView(
        workoutId: _selectedWorkoutIdForActive,
        onWorkoutFinished: () {
          setState(() {
            _selectedWorkoutIdForActive = null;
            _currentIndex = 0; // Retorna à tela inicial após concluir o treino
          });
        },
      ),
      const ProgressView(),
      ProfileView(
        onStartWorkout: (id) => _startWorkout(id),
        onNavigateToWorkouts: () => _onTabTapped(1),
        onNavigateToProgress: () => _onTabTapped(3),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: StitchBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
