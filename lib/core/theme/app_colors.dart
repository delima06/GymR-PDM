import 'package:flutter/material.dart';

/// Paleta de cores oficial baseada no Design System "Kinetic Neon Performance" do Stitch.
class AppColors {
  // Cores de Fundo e Superfície (OLED Minimalist)
  static const Color background = Color(0xFF0B0C0E); // Deep obsidian canvas
  static const Color surfaceCard = Color(0xFF131418); // Cards e blocos principais
  static const Color surfaceElevated = Color(0xFF1C1E24); // Modais, bottom sheets, inputs
  static const Color surfaceContainer = Color(0xFF1F1F23);
  static const Color surfaceBorder = Color(0x12FFFFFF); // Borda suave hairline (7% branco)
  static const Color surfaceBorderActive = Color(0x3310D85E); // Borda com leve glow neon

  // Destaques Neon (Kinetic Energy)
  static const Color primaryNeon = Color(0xFF10D85E); // Verde neon principal
  static const Color primaryNeonEnd = Color(0xFF00DE64); // Gradiente neon
  static const Color primaryNeonGlow = Color(0x4710D85E); // 28% de opacidade para glow
  static const Color secondaryNeon = Color(0xFF6BFF83); // Acentos secundários

  // Tipografia
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E939E);
  static const Color textMuted = Color(0xFF5E626E);
  static const Color textOnNeon = Color(0xFF0B150E); // Texto em cima de botões verdes neon

  // Feedback e Status
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF4D4D);
  static const Color success = Color(0xFF10D85E);
  static const Color info = Color(0xFF38BDF8);

  // Gradiente Neon Primário
  static const LinearGradient neonGradient = LinearGradient(
    colors: [primaryNeon, primaryNeonEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
