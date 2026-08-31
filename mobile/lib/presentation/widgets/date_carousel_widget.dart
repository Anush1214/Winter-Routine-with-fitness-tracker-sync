import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/utils/timeline_utils.dart';
import '../../core/audio/sound_service.dart';

class DateCarouselWidget extends StatefulWidget {
  final String selectedDate;
  final Function(String date) onSelectDate;
  final Map<String, double> dayStatsMap;

  const DateCarouselWidget({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
    required this.dayStatsMap,
  });

  @override
  State<DateCarouselWidget> createState() => _DateCarouselWidgetState();
}

class _DateCarouselWidgetState extends State<DateCarouselWidget> {
  late ScrollController _scrollController;
  final List<String> _allDays = TimelineUtils.getAll122Days(DateTime.now().year);

  @override
  void initState() {
    super.initState();
    final initialIndex = _allDays.indexOf(widget.selectedDate).clamp(0, _allDays.length - 1);
    _scrollController = ScrollController(
      initialScrollOffset: (initialIndex * 70.0).clamp(0.0, _allDays.length * 70.0),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: SoloColors.neonCyan, size: 14),
                const SizedBox(width: 6),
                Text("[ 122-DAY TIMELINE CAROUSEL ]", style: SoloTypography.systemTag),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: SoloColors.neonCyan, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    final idx = _allDays.indexOf(widget.selectedDate);
                    if (idx > 0) {
                      widget.onSelectDate(_allDays[idx - 1]);
                      _scrollController.animateTo(
                        ((idx - 1) * 70.0),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: SoloColors.neonCyan, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    final idx = _allDays.indexOf(widget.selectedDate);
                    if (idx < _allDays.length - 1) {
                      widget.onSelectDate(_allDays[idx + 1]);
                      _scrollController.animateTo(
                        ((idx + 1) * 70.0),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _allDays.length,
            itemBuilder: (context, index) {
              final dateStr = _allDays[index];
              final d = DateTime.parse(dateStr);
              final isSelected = dateStr == widget.selectedDate;
              final dayNum = TimelineUtils.getDayNumber(d);
              final rate = widget.dayStatsMap[dateStr] ?? 0.0;
              final monthStr = DateFormat('MMM').format(d).toUpperCase();
              final dayOfMonth = d.day;

              return GestureDetector(
                onTap: () {
                  SoundService().playClick();
                  widget.onSelectDate(dateStr);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 62,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF042F2E)
                        : SoloColors.obsidianGlass.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? SoloColors.neonCyan : SoloColors.neonCyan.withOpacity(0.2),
                      width: isSelected ? 1.5 : 0.8,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: SoloColors.neonCyan.withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "DAY $dayNum",
                        style: SoloTypography.systemTag.copyWith(
                          fontSize: 8,
                          color: isSelected ? SoloColors.neonCyan : SoloColors.textDim,
                        ),
                      ),
                      Text(
                        "$monthStr $dayOfMonth",
                        style: SoloTypography.questTitle.copyWith(
                          fontSize: 12,
                          color: isSelected ? Colors.white : SoloColors.textMuted,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: rate >= 100
                              ? SoloColors.rankEmerald
                              : rate > 0
                                  ? SoloColors.manaBlue
                                  : SoloColors.obsidianVoid,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "${rate.toInt()}%",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: rate >= 100 ? SoloColors.obsidianVoid : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
