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
      left: 18,
      right: 18,
      bottom: 22,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              // Liquid Ambient Glow
              BoxShadow(
                color: const Color(0xFFA855F7).withValues(alpha: 0.32),
                blurRadius: 36,
                spreadRadius: -2,
                offset: const Offset(0, 12),
              ),
              // Physics Depth Shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      const Color(0xFF1E1038).withValues(alpha: 0.72),
                      const Color(0xFF0A0518).withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.32),
                    width: 1.2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Top-edge Liquid Glass Specular Shine
                    Positioned(
                      top: 0,
                      left: 20,
                      right: 20,
                      height: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Navbar Action Items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // 1. Quests / Home
                        _LiquidNavItem(
                          icon: Icons.home_filled,
                          isSelected: selectedIndex == 0,
                          onTap: () => onTabSelected(0),
                        ),

                        // 2. Stats / Heatmap Matrix
                        _LiquidNavItem(
                          icon: Icons.show_chart_rounded,
                          isSelected: selectedIndex == 1,
                          onTap: () => onTabSelected(1),
                        ),

                        // 3. Center Elevated Liquid Add Button
                        GestureDetector(
                          onTap: () {
                            SoundService().playLevelUp();
                            onAddQuest();
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE9D5FF), Color(0xFFC084FC), Color(0xFF7E22CE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFA855F7).withValues(alpha: 0.65),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.8,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_rounded,
                                color: Color(0xFF1E0836),
                                size: 28,
                              ),
                            ),
                          ),
                        ),

                        // 4. Alerts / Alarms
                        _LiquidNavItem(
                          icon: Icons.notifications_none_rounded,
                          isSelected: selectedIndex == 2,
                          onTap: () => onTabSelected(2),
                        ),

                        // 5. Profile / Hunter Status
                        _LiquidNavItem(
                          icon: Icons.person_rounded,
                          isSelected: selectedIndex == 3,
                          photoUrl: userPhotoUrl,
                          onTap: () => onTabSelected(3),
                        ),
                      ],
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

class _LiquidNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? photoUrl;

  const _LiquidNavItem({
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
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
          border: isSelected
              ? Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.0,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withValues(alpha: 0.4),
                    blurRadius: 14,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.white54,
                    width: 1.4,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      icon,
                      size: 20,
                      color: isSelected ? const Color(0xFFFAF5FF) : Colors.white60,
                    ),
                  ),
                ),
              )
            : Icon(
                icon,
                size: 22,
                color: isSelected ? const Color(0xFFFAF5FF) : Colors.white60,
              ),
      ),
    );
  }
}
