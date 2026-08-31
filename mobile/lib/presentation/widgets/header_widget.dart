import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';
import '../../core/utils/timeline_utils.dart';
import '../../services/auth_service.dart';
import 'hunter_rank_badge.dart';
import 'holographic_frame.dart';
import '../screens/profile_screen.dart';

class HeaderWidget extends StatefulWidget {
  final String currentDate;
  final int activeStreak;
  final VoidCallback onOpenTaskModal;
  final VoidCallback onOpenNotificationModal;
  final VoidCallback onOpenSmartwatchModal;

  const HeaderWidget({
    super.key,
    required this.currentDate,
    required this.activeStreak,
    required this.onOpenTaskModal,
    required this.onOpenNotificationModal,
    required this.onOpenSmartwatchModal,
  });

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  late Timer _timer;
  String _timeStr = "";

  @override
  void initState() {
    super.initState();
    _updateClock();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      _timeStr = "${DateFormat('hh:mm:ss a').format(now)} IST";
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isFemale = auth.isFemaleTheme;
    final themeColor = isFemale ? const Color(0xFFFBBF24) : const Color(0xFFC084FC);
    final themeShadow = isFemale ? const Color(0xFFF59E0B) : const Color(0xFFA855F7);
    final systemTitle = isFemale ? "S-Rank Dancer" : "Shadow Monarch";

    final date = DateTime.tryParse(widget.currentDate) ?? DateTime.now();
    final dayNum = TimelineUtils.getDayNumber(date);
    final hunter = auth.currentUser;
    final hunterName = hunter?.displayName ?? systemTitle;

    return HolographicFrame(
      padding: const EdgeInsets.all(16),
      borderColor: themeColor,
      child: Column(
        children: [
          // Top Identity Row
          Row(
            children: [
              // Glowing Crown / S-Rank Emblem
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFemale
                        ? [const Color(0x66FDE047), const Color(0x44F59E0B), const Color(0x221E1005)]
                        : [const Color(0x5500F0FF), const Color(0x330284C7), const Color(0x2202050E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: themeShadow.withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      isFemale ? Icons.workspace_premium_rounded : Icons.workspace_premium,
                      color: themeColor,
                      size: 26,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: themeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isFemale ? const Color(0xFF291B08) : const Color(0xFF042F2E),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            "[ SYSTEM : $hunterName ]",
                            style: SoloTypography.systemTag.copyWith(fontSize: 8, color: themeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "WINTER ARC PROTOCOL",
                      style: SoloTypography.systemTitle.copyWith(
                        fontSize: 16,
                        color: isFemale ? const Color(0xFFFEF08A) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          "LEVEL $dayNum / 122",
                          style: SoloTypography.systemTag.copyWith(
                            fontSize: 10,
                            color: isFemale ? const Color(0xFFFDE047) : SoloColors.electricSky,
                          ),
                        ),
                        const SizedBox(width: 6),
                        HunterRankBadge(streakDays: widget.activeStreak),
                        const SizedBox(width: 6),
                        Text(
                          "• SEPT 1 — DEC 31",
                          style: SoloTypography.bodyMuted.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Profile Avatar → Navigate to Profile Screen
              GestureDetector(
                onTap: () {
                  SoundService().playClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(streakDays: widget.activeStreak),
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: themeColor.withValues(alpha: 0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: themeShadow.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: const Color(0xFF1E293B),
                    backgroundImage: hunter?.photoUrl != null
                        ? NetworkImage(hunter!.photoUrl!)
                        : null,
                    child: hunter?.photoUrl == null
                        ? Text(
                            hunterName.isNotEmpty ? hunterName[0].toUpperCase() : '?',
                            style: SoloTypography.systemTag.copyWith(
                              fontSize: 14,
                              color: themeColor,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: themeColor.withValues(alpha: 0.25), height: 1),
          const SizedBox(height: 12),

          // Top Controls: STREAK, LIVE CLOCK, & NOTIFICATIONS (ALERTS)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Streak Flame Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF431407),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SoloColors.flameOrange.withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: SoloColors.flameOrange.withValues(alpha: 0.25),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, color: SoloColors.flameOrange, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.activeStreak}D STREAK",
                        style: SoloTypography.systemTag.copyWith(
                          color: SoloColors.flameOrange,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Live IST Clock
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090314),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: themeColor.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_filled_rounded, color: themeColor, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        _timeStr,
                        style: SoloTypography.systemTag.copyWith(
                          fontSize: 10.5,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Notification / Alerts Hub (Beside Live Time/Clock)
                GestureDetector(
                  onTap: () {
                    SoundService().playClick();
                    widget.onOpenNotificationModal();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090314),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: themeColor.withValues(alpha: 0.45)),
                      boxShadow: [
                        BoxShadow(
                          color: themeShadow.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_active_rounded, color: themeColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Alerts",
                          style: SoloTypography.systemTag.copyWith(
                            fontSize: 10.5,
                            color: themeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
