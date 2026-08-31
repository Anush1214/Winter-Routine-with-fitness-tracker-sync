import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';

class HunterRankBadge extends StatelessWidget {
  final int streakDays;

  const HunterRankBadge({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    String rank = "E-RANK";
    Color color = SoloColors.textMuted;
    Color bg = const Color(0xFF0F172A);

    if (streakDays >= 30) {
      rank = "S-RANK MONARCH";
      color = SoloColors.neonCyan;
      bg = const Color(0xFF082F49);
    } else if (streakDays >= 20) {
      rank = "A-RANK";
      color = SoloColors.manaViolet;
      bg = const Color(0xFF2E1065);
    } else if (streakDays >= 10) {
      rank = "B-RANK";
      color = SoloColors.monarchGold;
      bg = const Color(0xFF451A03);
    } else if (streakDays >= 5) {
      rank = "C-RANK";
      color = SoloColors.rankEmerald;
      bg = const Color(0xFF064E3B);
    } else if (streakDays >= 1) {
      rank = "D-RANK";
      color = SoloColors.electricSky;
      bg = const Color(0xFF0C4A6E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        rank,
        style: SoloTypography.systemTag.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
