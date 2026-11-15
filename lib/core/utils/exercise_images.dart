import 'package:flutter/material.dart';

/// Helper de carregamento de imagens locais offline para exercícios e assets do GymR.
/// Garante operação 100% offline com zero requisições HTTP externas.
class ExerciseImageHelper {
  static const String placeholderAsset = 'assets/images/exercise_placeholder.png';
  static const String coachNarezAsset = 'assets/images/coach_narez.png';
  static const String todayWorkoutCoverAsset = 'assets/images/workout_cover.png';
  static const String athleteAvatarAsset = 'assets/images/athlete_avatar.png';

  // Aliases para compatibilidade reversa
  static const String coachNarezUrl = coachNarezAsset;
  static const String todayWorkoutCoverUrl = todayWorkoutCoverAsset;
  static const String athleteAvatarUrl = athleteAvatarAsset;

  static const Map<String, String> _knownExerciseImages = {
    // ex-1
    'supino reto com barra': 'assets/exercises/ex-1-supino-reto.png',
    'supino reto': 'assets/exercises/ex-1-supino-reto.png',
    'ex-1': 'assets/exercises/ex-1-supino-reto.png',

    // ex-2
    'supino inclinado com halteres': 'assets/exercises/ex-2-supino-inclinado.png',
    'supino inclinado c/ halteres': 'assets/exercises/ex-2-supino-inclinado.png',
    'supino inclinado': 'assets/exercises/ex-2-supino-inclinado.png',
    'ex-2': 'assets/exercises/ex-2-supino-inclinado.png',

    // ex-3
    'crucifixo na polia (crossover)': 'assets/exercises/ex-3-crucifixo-polia.png',
    'crucifixo na polia': 'assets/exercises/ex-3-crucifixo-polia.png',
    'crossover': 'assets/exercises/ex-3-crucifixo-polia.png',
    'crucifixo': 'assets/exercises/ex-3-crucifixo-polia.png',
    'ex-3': 'assets/exercises/ex-3-crucifixo-polia.png',

    // ex-4
    'puxada aberta na frente': 'assets/exercises/ex-4-puxada-aberta.png',
    'puxada alta aberta': 'assets/exercises/ex-4-puxada-aberta.png',
    'puxada aberta': 'assets/exercises/ex-4-puxada-aberta.png',
    'puxada alta': 'assets/exercises/ex-4-puxada-aberta.png',
    'puxada': 'assets/exercises/ex-4-puxada-aberta.png',
    'ex-4': 'assets/exercises/ex-4-puxada-aberta.png',

    // ex-5
    'remada curvada com barra': 'assets/exercises/ex-5-remada-curvada.png',
    'remada curvada': 'assets/exercises/ex-5-remada-curvada.png',
    'remada': 'assets/exercises/ex-5-remada-curvada.png',
    'ex-5': 'assets/exercises/ex-5-remada-curvada.png',

    // ex-6
    'agachamento livre com barra': 'assets/exercises/ex-6-agachamento-livre.png',
    'agachamento livre': 'assets/exercises/ex-6-agachamento-livre.png',
    'agachamento': 'assets/exercises/ex-6-agachamento-livre.png',
    'ex-6': 'assets/exercises/ex-6-agachamento-livre.png',

    // ex-7
    'leg press 45°': 'assets/exercises/ex-7-leg-press-45.png',
    'leg press 45': 'assets/exercises/ex-7-leg-press-45.png',
    'leg press': 'assets/exercises/ex-7-leg-press-45.png',
    'ex-7': 'assets/exercises/ex-7-leg-press-45.png',

    // ex-8
    'mesa flexora': 'assets/exercises/ex-8-mesa-flexora.png',
    'flexora': 'assets/exercises/ex-8-mesa-flexora.png',
    'ex-8': 'assets/exercises/ex-8-mesa-flexora.png',

    // ex-9
    'desenvolvimento militar com halteres': 'assets/exercises/ex-9-desenvolvimento-militar.png',
    'desenvolvimento militar': 'assets/exercises/ex-9-desenvolvimento-militar.png',
    'desenvolvimento': 'assets/exercises/ex-9-desenvolvimento-militar.png',
    'ex-9': 'assets/exercises/ex-9-desenvolvimento-militar.png',

    // ex-10
    'elevação lateral com halteres': 'assets/exercises/ex-10-elevacao-lateral.png',
    'elevação lateral na polia': 'assets/exercises/ex-10-elevacao-lateral.png',
    'elevação lateral': 'assets/exercises/ex-10-elevacao-lateral.png',
    'elevacao lateral': 'assets/exercises/ex-10-elevacao-lateral.png',
    'ex-10': 'assets/exercises/ex-10-elevacao-lateral.png',

    // ex-11
    'rosca direta com barra w': 'assets/exercises/ex-11-rosca-direta.png',
    'rosca direta': 'assets/exercises/ex-11-rosca-direta.png',
    'rosca bíceps': 'assets/exercises/ex-11-rosca-direta.png',
    'ex-11': 'assets/exercises/ex-11-rosca-direta.png',

    // ex-12
    'tríceps corda na polia': 'assets/exercises/ex-12-triceps-corda.png',
    'tríceps corda': 'assets/exercises/ex-12-triceps-corda.png',
    'triceps corda': 'assets/exercises/ex-12-triceps-corda.png',
    'tríceps na polia': 'assets/exercises/ex-12-triceps-corda.png',
    'ex-12': 'assets/exercises/ex-12-triceps-corda.png',

    // ex-13
    'prancha isométrica': 'assets/exercises/ex-13-prancha-isometrica.png',
    'prancha isometrica': 'assets/exercises/ex-13-prancha-isometrica.png',
    'prancha': 'assets/exercises/ex-13-prancha-isometrica.png',
    'ex-13': 'assets/exercises/ex-13-prancha-isometrica.png',
  };

  /// Retorna o caminho do asset local para o exercício indicado.
  static String getExerciseAsset(String exerciseName, {String? mediaUrl}) {
    if (mediaUrl != null && mediaUrl.isNotEmpty && mediaUrl.startsWith('assets/')) {
      return mediaUrl;
    }

    final lower = exerciseName.toLowerCase().trim();
    if (lower.isEmpty) {
      return placeholderAsset;
    }
    if (_knownExerciseImages.containsKey(lower)) {
      return _knownExerciseImages[lower]!;
    }

    for (final entry in _knownExerciseImages.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        return entry.value;
      }
    }

    return placeholderAsset;
  }

  /// Retorna o caminho do asset local para compatibilidade com chamadas legadas.
  static String? getExerciseImageUrl(String exerciseName) {
    return getExerciseAsset(exerciseName);
  }

  /// Constrói um widget [Image] localmente a partir dos assets empacotados.
  static Widget getExerciseImage(
    String exerciseName, {
    String? mediaUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    final assetPath = getExerciseAsset(exerciseName, mediaUrl: mediaUrl);
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ??
          Image.asset(
            placeholderAsset,
            width: width,
            height: height,
            fit: fit,
          ),
    );
  }

  /// Retorna um [ImageProvider] para o asset local do exercício.
  static ImageProvider getExerciseImageProvider(
    String exerciseName, {
    String? mediaUrl,
  }) {
    return AssetImage(getExerciseAsset(exerciseName, mediaUrl: mediaUrl));
  }
}
