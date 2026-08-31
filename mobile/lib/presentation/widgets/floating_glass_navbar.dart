import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/audio/sound_service.dart';

class FloatingGlassNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final VoidCallback onAddQuest;
  final String? userPhotoUrl;

  const FloatingGlassNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onAddQuest,
    this.userPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 24,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: -2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0826).withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // 1. Quests / Home
                    _NavItem(
                      icon: Icons.home_filled,
                      isSelected: selectedIndex == 0,
                      onTap: () => onTabSelected(0),
                    ),

                    // 2. Stats / Heatmap Matrix
                    _NavItem(
                      icon: Icons.show_chart_rounded,
                      isSelected: selectedIndex == 1,
                      onTap: () => onTabSelected(1),
                    ),

                    // 3. Center Elevated Add Button
                    GestureDetector(
                      onTap: () {
                        SoundService().playLevelUp();
                        onAddQuest();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC084FC), Color(0xFF7E22CE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFA855F7).withValues(alpha: 0.6),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),

                    // 4. Alerts / Alarms
                    _NavItem(
                      icon: Icons.notifications_none_rounded,
                      isSelected: selectedIndex == 2,
                      onTap: () => onTabSelected(2),
                    ),

                    // 5. Profile / Hunter Status
                    _NavItem(
                      icon: Icons.person_rounded,
                      isSelected: selectedIndex == 3,
                      photoUrl: userPhotoUrl,
                      onTap: () => onTabSelected(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? photoUrl;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService().playClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA855F7).withValues(alpha: 0.28)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFFC084FC).withValues(alpha: 0.8),
                  width: 1.2,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFC084FC) : Colors.white54,
                    width: 1.2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      icon,
                      size: 18,
                      color: isSelected ? const Color(0xFFC084FC) : Colors.white54,
                    ),
                  ),
                ),
              )
            : Icon(
                icon,
                size: 22,
                color: isSelected ? const Color(0xFFE9D5FF) : Colors.white54,
              ),
      ),
    );
  }
}
