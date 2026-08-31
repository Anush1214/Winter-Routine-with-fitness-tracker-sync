import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final date = DateTime.tryParse(widget.currentDate) ?? DateTime.now();
    final dayNum = TimelineUtils.getDayNumber(date);
    final hunter = AuthService().currentUser;
    final hunterName = hunter?.displayName ?? "Sung Jin-Woo";

    return HolographicFrame(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top Identity Row
          Row(
            children: [
              // Glowing Crown Emblem
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x5500F0FF), Color(0x330284C7), Color(0x2202050E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SoloColors.neonCyan, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: SoloColors.neonCyan.withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.workspace_premium, color: SoloColors.neonCyan, size: 26),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: SoloColors.neonCyan,
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
                            color: const Color(0xFF042F2E),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SoloColors.neonCyan.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            "[ SYSTEM : $hunterName ]",
                            style: SoloTypography.systemTag.copyWith(fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "WINTER ARC PROTOCOL",
                      style: SoloTypography.systemTitle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          "LEVEL $dayNum / 122",
                          style: SoloTypography.systemTag.copyWith(
                            fontSize: 10,
                            color: SoloColors.electricSky,
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
                    border: Border.all(color: SoloColors.neonCyan.withValues(alpha: 0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: SoloColors.neonCyan.withValues(alpha: 0.2),
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
                              color: SoloColors.neonCyan,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0x3300F0FF), height: 1),
          const SizedBox(height: 12),

          // Controls & Action Buttons Bar
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Streak Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF431407),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SoloColors.flameOrange.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: SoloColors.flameOrange.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: SoloColors.flameOrange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.activeStreak}D STREAK",
                      style: SoloTypography.systemTag.copyWith(color: SoloColors.flameOrange),
                    ),
                  ],
                ),
              ),

              // Live IST Clock
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: SoloColors.obsidianVoid,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SoloColors.neonCyan.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, color: SoloColors.neonCyan, size: 12),
                    const SizedBox(width: 4),
                    Text(_timeStr, style: SoloTypography.systemTag.copyWith(fontSize: 10)),
                  ],
                ),
              ),

              // Sound Toggle
              GestureDetector(
                onTap: () {
                  SoundService().toggleSound();
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: SoloColors.obsidianVoid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SoloColors.neonCyan.withValues(alpha: 0.4)),
                  ),
                  child: Icon(
                    SoundService().isSoundEnabled ? Icons.volume_up : Icons.volume_off,
                    color: SoundService().isSoundEnabled ? SoloColors.neonCyan : SoloColors.textDim,
                    size: 16,
                  ),
                ),
              ),

              // Alerts Hub
              GestureDetector(
                onTap: widget.onOpenNotificationModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: SoloColors.obsidianVoid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SoloColors.neonCyan.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications_none, color: SoloColors.neonCyan, size: 14),
                      const SizedBox(width: 4),
                      Text("Alerts", style: SoloTypography.systemTag.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
              ),

              // Smartwatch Sync
              GestureDetector(
                onTap: widget.onOpenSmartwatchModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: SoloColors.obsidianVoid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SoloColors.manaViolet.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.watch_outlined, color: SoloColors.manaViolet, size: 14),
                      const SizedBox(width: 4),
                      Text("Watch Sync", style: SoloTypography.systemTag.copyWith(color: SoloColors.manaViolet, fontSize: 10)),
                    ],
                  ),
                ),
              ),

              // + Add Quest Button
              GestureDetector(
                onTap: widget.onOpenTaskModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: SoloColors.buttonCyanGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: SoloColors.neonCyan.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: SoloColors.obsidianVoid, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "+ Add Quest",
                        style: SoloTypography.systemTag.copyWith(
                          color: SoloColors.obsidianVoid,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
