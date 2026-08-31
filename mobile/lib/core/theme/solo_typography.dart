import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'solo_colors.dart';

class SoloTypography {
  static const List<String> _cjkFallback = [
    'Noto Sans JP',
    'Hiragino Sans',
    'Yu Gothic',
    'Meiryo',
    'sans-serif',
  ];

  static TextStyle get systemTitle => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: Colors.white,
        shadows: [
          const Shadow(
            color: Color(0x9900F0FF),
            blurRadius: 15,
          ),
        ],
      );

  static TextStyle get questTitle => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: SoloColors.textGlowWhite,
      );

  static TextStyle get systemTag => GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: SoloColors.neonCyan,
      );

  static TextStyle get monoValue => GoogleFonts.jetBrainsMono(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        shadows: [
          const Shadow(
            color: Color(0x6600F0FF),
            blurRadius: 10,
          ),
        ],
      );

  static TextStyle get bodyMuted => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: SoloColors.textMuted,
      );

  static TextStyle get warningText => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: SoloColors.penaltyCrimson,
      );

  static TextStyle japaneseQuote({double fontSize = 13, Color color = Colors.white}) =>
      GoogleFonts.notoSansJp(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.45,
      );

  static TextStyle englishSubtitle({double fontSize = 12, Color color = const Color(0xFFFACC15)}) =>
      GoogleFonts.outfit(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        color: color,
        height: 1.35,
        shadows: const [
          Shadow(
            color: Colors.black,
            blurRadius: 4,
            offset: Offset(1, 1),
          ),
        ],
      );
}
