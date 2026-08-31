import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/utils/timeline_utils.dart';
import 'holographic_frame.dart';

class ExpeditionMatrix extends StatelessWidget {
  final Map<String, double> heatmapRates;
  final String selectedDate;
  final Function(String date) onSelectDate;

  const ExpeditionMatrix({
    super.key,
    required this.heatmapRates,
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final allDays = TimelineUtils.getAll122Days(year);

    return HolographicFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "[ HUNTER EXPEDITION MATRIX ]",
                style: SoloTypography.systemTag,
              ),
              Text(
                "SEPT 1 — DEC 31",
                style: SoloTypography.bodyMuted.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Horizontal scrolling matrix strip
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allDays.length,
              itemBuilder: (context, index) {
                final dateStr = allDays[index];
                final rate = heatmapRates[dateStr] ?? 0.0;
                final isSelected = dateStr == selectedDate;
                final dayNum = DateTime.parse(dateStr).day;

                Color cellColor = SoloColors.obsidianVoid;
                if (rate >= 100) {
                  cellColor = SoloColors.neonCyan;
                } else if (rate >= 75) {
                  cellColor = SoloColors.manaBlue;
                } else if (rate >= 50) {
                  cellColor = SoloColors.deepMana;
                } else if (rate > 0) {
                  cellColor = const Color(0xFF0F2B48);
                }

                return GestureDetector(
                  onTap: () => onSelectDate(dateStr),
                  child: Container(
                    width: 32,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? Colors.white : SoloColors.neonCyan.withOpacity(0.3),
                        width: isSelected ? 1.5 : 0.8,
                      ),
                      boxShadow: isSelected
                          ? [
                              const BoxShadow(
                                color: SoloColors.neonCyan,
                                blurRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        dayNum.toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: rate >= 100 ? SoloColors.obsidianVoid : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
