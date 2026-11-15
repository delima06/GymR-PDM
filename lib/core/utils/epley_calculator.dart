/// Calculadora científica de 1RM e progressão de carga fundamentada
/// na Equação de Epley: 1RM = Carga * (1 + Reps / 30)
class EpleyCalculator {
  /// Calcula a estimativa de 1 Repetição Máxima (1RM)
  /// Para 1 repetição, 1RM é idêntico à carga erguida.
  static double calculate1RM(double weightKg, int reps) {
    if (weightKg <= 0) return 0.0;
    if (reps <= 1) return weightKg;
    return weightKg * (1.0 + (reps / 30.0));
  }

  /// Regra de Sobrecarga Progressiva:
  /// Se o atleta completou as repetições alvo máximas (targetMaxReps, padrão 12)
  /// na carga atual, recomenda-se incremento de sobrecarga.
  static bool shouldProgressWeight(int repsPerformed, [int targetMaxReps = 12]) {
    if (repsPerformed <= 0 || targetMaxReps <= 0) return false;
    return repsPerformed >= targetMaxReps;
  }

  /// Sugestão de carga para o próximo ciclo de sobrecarga progressiva.
  /// Incremento padrão de +2.5 kg para sobrecarga gradual e segura.
  static double suggestNextWeight(double currentWeightKg, [double incrementKg = 2.5]) {
    if (currentWeightKg <= 0) return incrementKg;
    return currentWeightKg + incrementKg;
  }
}

