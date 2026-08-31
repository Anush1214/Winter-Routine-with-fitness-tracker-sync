import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import 'holographic_frame.dart';

class HydrationWaveCard extends StatelessWidget {
  final int waterIntakeMl;
  final int goalMl;
  final Function(int delta) onUpdateWater;

  const HydrationWaveCard({
    super.key,
    required this.waterIntakeMl,
    this.goalMl = 4500,
    required this.onUpdateWater,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (waterIntakeMl / goalMl).clamp(0.0, 1.0);

    return HolographicFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: SoloColors.obsidianVoid,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: SoloColors.neonCyan.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.water_drop, color: SoloColors.neonCyan, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("[ STAT: VITALITY ]", style: SoloTypography.systemTag),
                      Text("Hydration Chamber", style: SoloTypography.questTitle.copyWith(fontSize: 14)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: SoloColors.obsidianVoid,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: SoloColors.neonCyan.withOpacity(0.4)),
                ),
                child: Text(
                  "${(percent * 100).toInt()}%",
                  style: SoloTypography.systemTag,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                waterIntakeMl.toString(),
                style: SoloTypography.monoValue.copyWith(fontSize: 26),
              ),
              const SizedBox(width: 4),
              Text(
                "/ $goalMl ml",
                style: SoloTypography.bodyMuted.copyWith(color: SoloColors.neonCyan),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Fluid progress bar
          Container(
            height: 18,
            width: double.infinity,
            decoration: BoxDecoration(
              color: SoloColors.obsidianVoid,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: SoloColors.neonCyan.withOpacity(0.3)),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [SoloColors.neonCyan, SoloColors.manaBlue, SoloColors.electricSky],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: SoloColors.neonCyan.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Quick Tap Buttons
          Row(
            children: [
              Expanded(
                child: _QuickWaterButton(
                  label: "+250ml",
                  onTap: () {
                    SoundService().playWaterDrop();
                    onUpdateWater(250);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickWaterButton(
                  label: "+500ml",
                  onTap: () {
                    SoundService().playWaterDrop();
                    onUpdateWater(500);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickWaterButton(
                  label: "-250ml",
                  isNegative: true,
                  onTap: () {
                    SoundService().playClick();
                    onUpdateWater(-250);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickWaterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isNegative;

  const _QuickWaterButton({
    required this.label,
    required this.onTap,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: SoloColors.obsidianVoid,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isNegative
                ? SoloColors.textDim.withOpacity(0.3)
                : SoloColors.neonCyan.withOpacity(0.4),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: SoloTypography.systemTag.copyWith(
              color: isNegative ? SoloColors.textDim : SoloColors.neonCyan,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
