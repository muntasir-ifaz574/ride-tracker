import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF10B981);
  static const Color primaryTint = Color(0x2610B981);
  static const Color secondary = Color(0xFF6366F1);
  static const Color accent = Color(0xFF38BDF8);
  static const Color rating = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFEF4444);

  // Dark Neutrals (Slate Palette)
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color border = Color(0xFF334155);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Gradient bottomSheetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  static const Gradient completionGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
}
