import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/exercise_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'ui/dashboard/dashboard_view_model.dart';
import 'ui/workouts/workouts_view_model.dart';
import 'ui/main_navigation_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Instâncias singleton dos repositórios
  final exerciseRepository = ExerciseRepository();
  final workoutRepository = WorkoutRepository();

  runApp(
    MultiProvider(
      providers: [
        // Injeção dos Repositórios para a camada de Dados (Data Layer)
        Provider<ExerciseRepository>.value(value: exerciseRepository),
        Provider<WorkoutRepository>.value(value: workoutRepository),

        // Injeção dos ViewModels (UI Layer - MVVM)
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(workoutRepository: workoutRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutsViewModel(workoutRepository: workoutRepository),
        ),
      ],
      child: const GymRApp(),
    ),
  );
}

class GymRApp extends StatelessWidget {
  const GymRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymR - Workout Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScaffold(),
    );
  }
}
