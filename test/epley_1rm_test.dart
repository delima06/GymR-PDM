import 'package:flutter_test/flutter_test.dart';
import 'package:gymr/core/utils/epley_calculator.dart';

void main() {
  group('Cálculo Científico de 1RM (EpleyCalculator de Produção)', () {
    test('Para 1 repetição máxima, 1RM deve ser idêntico à carga erguida', () {
      final rm = EpleyCalculator.calculate1RM(100.0, 1);
      expect(rm, 100.0);
    });

    test('Supino: 80 kg para 10 reps deve estimar 1RM em aproximadamente 106.67 kg', () {
      final rm = EpleyCalculator.calculate1RM(80.0, 10);
      expect(rm, closeTo(106.67, 0.01));
    });

    test('Agachamento: 140 kg para 5 reps deve estimar 1RM em aproximadamente 163.33 kg', () {
      final rm = EpleyCalculator.calculate1RM(140.0, 5);
      expect(rm, closeTo(163.33, 0.01));
    });

    test('Carga zero ou negativa retorna zero', () {
      expect(EpleyCalculator.calculate1RM(0.0, 10), 0.0);
      expect(EpleyCalculator.calculate1RM(-10.0, 5), 0.0);
    });

    test('Sugestão de Sobrecarga Progressiva: reps >= 12 recomenda aumento de carga', () {
      expect(EpleyCalculator.shouldProgressWeight(8), isFalse);
      expect(EpleyCalculator.shouldProgressWeight(10), isFalse);
      expect(EpleyCalculator.shouldProgressWeight(11), isFalse);
      expect(EpleyCalculator.shouldProgressWeight(12), isTrue);
      expect(EpleyCalculator.shouldProgressWeight(15), isTrue);
    });
  });
}
