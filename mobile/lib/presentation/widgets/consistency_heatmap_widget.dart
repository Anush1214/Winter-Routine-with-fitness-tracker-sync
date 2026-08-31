import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import 'holographic_frame.dart';

class ConsistencyHeatmapWidget extends StatelessWidget {
  final Map<String, double> heatmapRates;
  final String selectedDate;
  final Function(String date) onSelectDate;

  const ConsistencyHeatmapWidget({
    super.key,
    required this.heatmapRates,
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;

    final months = [
      {'name': 'SEPTEMBER', 'days': 30, 'month': 9},
      {'name': 'OCTOBER', 'days': 31, 'month': 10},
      {'name': 'NOVEMBER', 'days': 30, 'month': 11},
      {'name': 'DECEMBER', 'days': 31, 'month': 12},
    ];

    return HolographicFrame(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_view, color: SoloColors.neonCyan, size: 16),
                  const SizedBox(width: 8),
                  Text("[ 122-DAY HUNTER EXPEDITION MATRIX ]", style: SoloTypography.systemTag),
                ],
              ),
              Text(
                "SEPT 1 — DEC 31",
                style: SoloTypography.bodyMuted.copyWith(fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4-Month Matrices Grid
          ...months.map((m) {
            final monthNum = m['month'] as int;
            final daysInMonth = m['days'] as int;
            final monthName = m['name'] as String;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthName,
                  style: SoloTypography.systemTag.copyWith(
                    fontSize: 10,
                    color: SoloColors.electricSky,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(daysInMonth, (index) {
                    final day = index + 1;
                    final dateKey = "$year-${monthNum.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
                    final rate = heatmapRates[dateKey] ?? 0.0;
                    final isSelected = dateKey == selectedDate;

                    Color cellColor = SoloColors.obsidianVoid;
                    if (rate >= 100) {
                      cellColor = SoloColors.neonCyan;
                    } else if (rate >= 75) {
                      cellColor = SoloColors.manaBlue;
                    } else if (rate >= 50) {
                      cellColor = SoloColors.deepMana;
                    } else if (rate > 0) {
                      cellColor = const Color(0xFF0C4A6E);
                    }

                    return GestureDetector(
                      onTap: () {
                        SoundService().playClick();
                        onSelectDate(dateKey);
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isSelected ? Colors.white : SoloColors.neonCyan.withOpacity(0.2),
                            width: isSelected ? 1.5 : 0.8,
                          ),
                          boxShadow: isSelected
                              ? [
                                  const BoxShadow(
                                    color: SoloColors.neonCyan,
                                    blurRadius: 8,
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: rate >= 100 ? SoloColors.obsidianVoid : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
              ],
            );
          }),

          const SizedBox(height: 6),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("PROGRESSION INTENSITY", style: SoloTypography.bodyMuted.copyWith(fontSize: 8)),
              Row(
                children: [
                  Text("0%", style: SoloTypography.bodyMuted.copyWith(fontSize: 8)),
                  const SizedBox(width: 4),
                  _buildLegendDot(SoloColors.obsidianVoid),
                  const SizedBox(width: 3),
                  _buildLegendDot(const Color(0xFF0C4A6E)),
                  const SizedBox(width: 3),
                  _buildLegendDot(SoloColors.deepMana),
                  const SizedBox(width: 3),
                  _buildLegendDot(SoloColors.manaBlue),
                  const SizedBox(width: 3),
                  _buildLegendDot(SoloColors.neonCyan),
                  const SizedBox(width: 4),
                  Text("100%", style: SoloTypography.bodyMuted.copyWith(fontSize: 8)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: SoloColors.neonCyan.withOpacity(0.3), width: 0.5),
      ),
    );
  }
}
