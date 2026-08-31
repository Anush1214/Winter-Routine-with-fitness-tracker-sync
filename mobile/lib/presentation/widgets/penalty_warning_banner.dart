import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';

class PenaltyWarningBanner extends StatelessWidget {
  const PenaltyWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: SoloColors.penaltyBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SoloColors.penaltyCrimson.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: SoloColors.penaltyCrimson.withOpacity(0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: SoloColors.penaltyCrimson, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: SoloTypography.warningText,
                children: const [
                  TextSpan(
                    text: "[ CAUTION ] ",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: "Failure to complete daily quests will result in a ",
                  ),
                  TextSpan(
                    text: "Penalty Quest.",
                    style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
