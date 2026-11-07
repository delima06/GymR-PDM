/// Modelo de domínio que representa um exercício do catálogo.
class Exercise {
  final String id;
  final String name;
  final String muscleGroup; // Peito, Costas, Pernas, Ombros, Braços, Core
  final String equipment; // Halteres, Barra, Máquina, Peso do corpo, Polia
  final String instructions;
  final List<String> secondaryMuscles;
  final String? mediaUrl; // Imagem, GIF ou Vídeo demonstrativo
  final bool isCustom;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.instructions,
    this.secondaryMuscles = const [],
    this.mediaUrl,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'instructions': instructions,
      'secondaryMuscles': secondaryMuscles.join(','),
      'mediaUrl': mediaUrl,
      'isCustom': isCustom ? 1 : 0,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscleGroup'] as String,
      equipment: map['equipment'] as String,
      instructions: map['instructions'] as String? ?? '',
      secondaryMuscles: map['secondaryMuscles'] != null && (map['secondaryMuscles'] as String).isNotEmpty
          ? (map['secondaryMuscles'] as String).split(',')
          : [],
      mediaUrl: map['mediaUrl'] as String?,
      isCustom: (map['isCustom'] as int? ?? 0) == 1,
    );
  }
}
