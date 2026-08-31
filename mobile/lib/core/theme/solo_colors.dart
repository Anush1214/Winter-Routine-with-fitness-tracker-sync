import 'package:flutter/material.dart';

class SoloColors {
  // Deep Awakening Obsidian & Violet Voids (Reference UI Theme)
  static const Color obsidianVoid = Color(0xFF090414);
  static const Color obsidianGlass = Color(0xFF130926);
  static const Color obsidianCard = Color(0xFF100722);
  static const Color obsidianBorder = Color(0xFF2A154D);

  // Awakening Purple & Orchid Mana Accents
  static const Color neonCyan = Color(0xFFC084FC); // Radiant Orchid Purple
  static const Color manaViolet = Color(0xFFA855F7); // Core Purple Mana
  static const Color manaBlue = Color(0xFF9333EA); // Deep Violet
  static const Color electricSky = Color(0xFFE9D5FF); // Soft Lavender Glow
  static const Color deepMana = Color(0xFF6B21A8); // Shadow Purple

  // Hunter Ranks & Accents
  static const Color monarchGold = Color(0xFFFFD700);
  static const Color flameOrange = Color(0xFFFB923C);
  static const Color rankEmerald = Color(0xFF34D399);
  
  // Penalty Alerts
  static const Color penaltyCrimson = Color(0xFFF43F5E);
  static const Color penaltyBg = Color(0xFF4C0519);

  // Typography & Neutrals
  static const Color textGlowWhite = Color(0xFFFAF5FF);
  static const Color textMuted = Color(0xFFA89BB9);
  static const Color textDim = Color(0xFF706284);

  // Gradients
  static const LinearGradient manaGradient = LinearGradient(
    colors: [Color(0xFFC084FC), Color(0xFFA855F7), Color(0xFF7E22CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xDD130926),
      Color(0xEE090414),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonCyanGradient = LinearGradient(
    colors: [Color(0xFFC084FC), Color(0xFF9333EA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient awakenButtonGradient = LinearGradient(
    colors: [Color(0xFFD8B4FE), Color(0xFFA855F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
