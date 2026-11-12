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
  /// Se o atleta completou 12 ou mais repetições na carga atual,
  /// recomenda-se incremento de sobrecarga.
  static bool shouldProgressWeight(int reps) {
    return reps >= 12;
  }
}

