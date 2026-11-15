import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymr/ui/widgets/stitch_bottom_nav_bar.dart';
import 'package:gymr/ui/profile/profile_view.dart';
import 'package:gymr/ui/profile/profile_view_model.dart';
import 'package:gymr/data/repositories/history_repository.dart';
import 'package:gymr/data/repositories/workout_repository.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('StitchBottomNavBar displays all 5 tabs and responds to tap', (tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: StitchBottomNavBar(
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Fichas'), findsOneWidget);
    expect(find.text('Treinar'), findsOneWidget);
    expect(find.text('Evolução'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    // Tap Perfil tab (index 4)
    await tester.tap(find.text('Perfil'));
    await tester.pump();
    expect(tappedIndex, 4);

    // Tap Fichas tab (index 1)
    await tester.tap(find.text('Fichas'));
    await tester.pump();
    expect(tappedIndex, 1);
  });

  testWidgets('ProfileView renders athlete information, biometrics, and records', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final vm = ProfileViewModel(
      historyRepository: HistoryRepository(),
      workoutRepository: WorkoutRepository(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ProfileViewModel>.value(
          value: vm,
          child: const ProfileView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verifica elementos do Card Principal
    expect(find.text('Atleta GymR'), findsOneWidget);
    expect(find.text('Gymr PRO'), findsOneWidget);
    expect(find.text('Membro Ativo'), findsOneWidget);

    // Verifica seções de Biometria e Conquistas
    expect(find.text('BIOMETRIA & METAS'), findsOneWidget);
    expect(find.text('ACESSO RÁPIDO & ROTINAS'), findsOneWidget);
    expect(find.text('CONQUISTAS & RECORDES'), findsOneWidget);
  });
}
