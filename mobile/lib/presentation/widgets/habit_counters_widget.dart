import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../services/auth_service.dart';
import 'holographic_frame.dart';

class HabitCountersWidget extends StatefulWidget {
  final int waterIntakeMl;
  final int steps;
  final int sleepMinutes;
  final Function(int delta, String mode) onUpdateWater;
  final VoidCallback onOpenSmartwatchModal;

  const HabitCountersWidget({
    super.key,
    required this.waterIntakeMl,
    required this.steps,
    required this.sleepMinutes,
    required this.onUpdateWater,
    required this.onOpenSmartwatchModal,
  });

  @override
  State<HabitCountersWidget> createState() => _HabitCountersWidgetState();
}

class _HabitCountersWidgetState extends State<HabitCountersWidget> {
  final TextEditingController _customWaterController = TextEditingController();

  @override
  void dispose() {
    _customWaterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFemale = context.watch<AuthService>().isFemaleTheme;
    final themeColor = isFemale ? const Color(0xFFFBBF24) : const Color(0xFFC084FC);
    final themeGlow = isFemale ? const Color(0xFFF59E0B) : const Color(0xFFA855F7);
    final themeHighlight = isFemale ? const Color(0xFFFDE047) : const Color(0xFFE9D5FF);

    final waterPercent = (widget.waterIntakeMl / 4500).clamp(0.0, 1.0);
    final stepsPercent = (widget.steps / 10000).clamp(0.0, 1.0);
    final sleepHours = (widget.sleepMinutes / 60).toStringAsFixed(1);
    final sleepPercent = (widget.sleepMinutes / 420).clamp(0.0, 1.0);
    final kmWalked = ((widget.steps * 0.76) / 1000).toStringAsFixed(1);
    final caloriesBurned = (widget.steps * 0.04).round();

    return Column(
      children: [
        // 1. Vitality - Hydration Chamber Card
        HolographicFrame(
          padding: const EdgeInsets.all(16),
          borderColor: themeColor,
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
                          color: isFemale ? const Color(0xFF291B08) : SoloColors.obsidianVoid,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                        ),
                        child: Icon(Icons.water_drop, color: themeColor, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "[ STAT: VITALITY ]",
                            style: SoloTypography.systemTag.copyWith(color: themeColor),
                          ),
                          Text(
                            "Hydration Chamber",
                            style: SoloTypography.questTitle.copyWith(
                              fontSize: 14,
                              color: isFemale ? const Color(0xFFFEF08A) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isFemale ? const Color(0xFF291B08) : SoloColors.obsidianVoid,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      "${(waterPercent * 100).toInt()}%",
                      style: SoloTypography.systemTag.copyWith(color: themeColor),
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
                    widget.waterIntakeMl.toString(),
                    style: SoloTypography.monoValue.copyWith(
                      fontSize: 26,
                      color: isFemale ? const Color(0xFFFDE047) : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "/ 4500 ml",
                    style: SoloTypography.bodyMuted.copyWith(color: themeColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Fluid bar (Dynamic Theme Gradient)
              Container(
                height: 18,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isFemale ? const Color(0xFF1E1005) : SoloColors.obsidianVoid,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: themeColor.withValues(alpha: 0.35)),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: waterPercent,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: isFemale
                                ? [const Color(0xFFF59E0B), const Color(0xFFFBBF24), const Color(0xFFFEF08A)]
                                : [const Color(0xFF7E22CE), const Color(0xFFA855F7), const Color(0xFFE9D5FF)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: themeGlow.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: "+250ml",
                      themeColor: themeColor,
                      onTap: () {
                        SoundService().playWaterDrop();
                        widget.onUpdateWater(250, 'increment');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: "+500ml",
                      themeColor: themeColor,
                      onTap: () {
                        SoundService().playWaterDrop();
                        widget.onUpdateWater(500, 'increment');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: "-250ml",
                      isNegative: true,
                      themeColor: themeColor,
                      onTap: () {
                        SoundService().playClick();
                        widget.onUpdateWater(-250, 'increment');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Strength - Step & Movement Card
        HolographicFrame(
          padding: const EdgeInsets.all(16),
          borderColor: themeColor,
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
                          color: isFemale ? const Color(0xFF291B08) : SoloColors.obsidianVoid,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                        ),
                        child: Icon(Icons.directions_walk, color: themeColor, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "[ STAT: STRENGTH ]",
                            style: SoloTypography.systemTag.copyWith(color: themeColor),
                          ),
                          Text(
                            "Movement Gauge",
                            style: SoloTypography.questTitle.copyWith(
                              fontSize: 14,
                              color: isFemale ? const Color(0xFFFEF08A) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isFemale ? const Color(0xFF291B08) : SoloColors.obsidianVoid,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      "${(stepsPercent * 100).toInt()}%",
                      style: SoloTypography.systemTag.copyWith(color: themeColor),
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
                    widget.steps.toString(),
                    style: SoloTypography.monoValue.copyWith(
                      fontSize: 26,
                      color: isFemale ? const Color(0xFFFDE047) : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "/ 10,000 steps",
                    style: SoloTypography.bodyMuted.copyWith(color: themeColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isFemale ? const Color(0xFF1E1005) : SoloColors.obsidianVoid,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: themeColor.withValues(alpha: 0.35)),
                ),
                child: FractionallySizedBox(
                  widthFactor: stepsPercent,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: isFemale
                            ? [const Color(0xFFEA580C), const Color(0xFFF59E0B), const Color(0xFFFDE047)]
                            : [const Color(0xFF6B21A8), const Color(0xFFA855F7), const Color(0xFFC084FC)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeGlow.withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isFemale ? const Color(0xFF291B08) : SoloColors.obsidianVoid,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("DISTANCE", style: SoloTypography.bodyMuted.copyWith(fontSize: 8)),
                          Text(
                            "$kmWalked km",
                            style: SoloTypography.systemTag.copyWith(color: themeColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isFemale ? const Color(0xFF291B08) : SoloColors.obsidianVoid,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("BURNED", style: SoloTypography.bodyMuted.copyWith(fontSize: 8)),
                          Text(
                            "$caloriesBurned kcal",
                            style: SoloTypography.systemTag.copyWith(color: const Color(0xFFF97316)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. Perception - Sleep Recovery Chamber
        HolographicFrame(
          padding: const EdgeInsets.all(16),
          borderColor: themeColor,
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
                          color: isFemale ? const Color(0xFF291B08) : SoloColors.obsidianVoid,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                        ),
                        child: Icon(Icons.nightlight_round, color: themeColor, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "[ STAT: RECOVERY ]",
                            style: SoloTypography.systemTag.copyWith(color: themeColor),
                          ),
                          Text(
                            "Restoration Chamber",
                            style: SoloTypography.questTitle.copyWith(
                              fontSize: 14,
                              color: isFemale ? const Color(0xFFFEF08A) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isFemale ? const Color(0xFF291B08) : SoloColors.obsidianVoid,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      "${(sleepPercent * 100).toInt()}%",
                      style: SoloTypography.systemTag.copyWith(color: themeColor),
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
                    "${sleepHours}h",
                    style: SoloTypography.monoValue.copyWith(
                      fontSize: 26,
                      color: isFemale ? const Color(0xFFFDE047) : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "(${widget.sleepMinutes} mins / 7h)",
                    style: SoloTypography.bodyMuted.copyWith(color: themeColor),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isFemale ? const Color(0xFF1E1005) : SoloColors.obsidianVoid,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: themeColor.withValues(alpha: 0.35)),
                ),
                child: FractionallySizedBox(
                  widthFactor: sleepPercent,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: isFemale
                            ? [const Color(0xFFD97706), const Color(0xFFFBBF24), const Color(0xFFFEF08A)]
                            : [const Color(0xFF581C87), const Color(0xFFA855F7), const Color(0xFFE9D5FF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeGlow.withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isFemale ? const Color(0xFF291B08) : SoloColors.obsidianVoid,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: themeColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("RESTORATION STATE", style: SoloTypography.bodyMuted.copyWith(fontSize: 9)),
                    Text(
                      widget.sleepMinutes >= 420 ? "[ OPTIMAL RECOVERY ]" : "[ BELOW THRESHOLD ]",
                      style: SoloTypography.systemTag.copyWith(
                        fontSize: 9,
                        color: widget.sleepMinutes >= 420 ? const Color(0xFF10B981) : themeHighlight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isNegative;
  final Color themeColor;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.isNegative = false,
    this.themeColor = const Color(0xFFC084FC),
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
                ? SoloColors.textDim.withValues(alpha: 0.3)
                : themeColor.withValues(alpha: 0.5),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: SoloTypography.systemTag.copyWith(
              color: isNegative ? SoloColors.textDim : themeColor,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
