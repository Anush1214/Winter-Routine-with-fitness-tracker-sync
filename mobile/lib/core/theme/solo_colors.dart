import 'package:flutter/material.dart';

class SoloColors {
  // Deep Holographic Voids
  static const Color obsidianVoid = Color(0xFF02050E);
  static const Color obsidianGlass = Color(0xFF061226);
  static const Color obsidianCard = Color(0xFF040C1B);
  static const Color obsidianBorder = Color(0xFF0E223D);

  // Solo Leveling Neon Cyans & Mana Blues
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color manaBlue = Color(0xFF0284C7);
  static const Color electricSky = Color(0xFF38BDF8);
  static const Color deepMana = Color(0xFF0369A1);
  static const Color manaViolet = Color(0xFF8B5CF6);

  // Hunter Ranks & Accents
  static const Color monarchGold = Color(0xFFF59E0B);
  static const Color flameOrange = Color(0xFFF97316);
  static const Color rankEmerald = Color(0xFF10B981);
  
  // Penalty Alerts
  static const Color penaltyCrimson = Color(0xFFEF4444);
  static const Color penaltyBg = Color(0xFF450A0A);

  // Typography & Neutrals
  static const Color textGlowWhite = Color(0xFFE2F4FF);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDim = Color(0xFF64748B);

  // Gradients
  static const LinearGradient manaGradient = LinearGradient(
    colors: [neonCyan, manaBlue, manaViolet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xCC061226),
      Color(0xEE020814),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonCyanGradient = LinearGradient(
    colors: [neonCyan, Color(0xFF0284C7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
