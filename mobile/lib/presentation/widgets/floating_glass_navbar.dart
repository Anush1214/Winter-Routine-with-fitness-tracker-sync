import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/audio/sound_service.dart';

class FloatingGlassNavbar extends StatefulWidget {
  final int selectedIndex;
  final int streakDays;
  final Function(int) onTabSelected;
  final VoidCallback onAddQuest;
  final VoidCallback onOpenWatchSync;
  final VoidCallback? onOpenGeminiAi;
  final VoidCallback? onStreakTap;
  final String? userPhotoUrl;
  final bool isFemaleTheme;

  const FloatingGlassNavbar({
    super.key,
    required this.selectedIndex,
    this.streakDays = 0,
    required this.onTabSelected,
    required this.onAddQuest,
    required this.onOpenWatchSync,
    this.onOpenGeminiAi,
    this.onStreakTap,
    this.userPhotoUrl,
    this.isFemaleTheme = false,
  });

  @override
  State<FloatingGlassNavbar> createState() => _FloatingGlassNavbarState();
}

class _FloatingGlassNavbarState extends State<FloatingGlassNavbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _flameController;

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _flameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isFemaleTheme
        ? const Color(0xFFFBBF24)
        : const Color(0xFFC084FC);
    final themeShadow = widget.isFemaleTheme
        ? const Color(0xFFF59E0B)
        : const Color(0xFFA855F7);

    return Positioned(
      left: 10,
      right: 10,
      bottom: 18,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: themeShadow.withValues(alpha: 0.35),
                blurRadius: 36,
                spreadRadius: -2,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.18),
                      widget.isFemaleTheme
                          ? const Color(0xFF291B08).withValues(alpha: 0.8)
                          : const Color(0xFF1E1038).withValues(alpha: 0.8),
                      const Color(0xFF07030E).withValues(alpha: 0.92),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
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
                              themeColor.withValues(alpha: 0.8),
                              Colors.white.withValues(alpha: 0.9),
                              themeColor.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 1. Home / Daily Protocols
                        _LiquidNavItem(
                          icon: Icons.shield_rounded,
                          tooltip: "Protocols",
                          isSelected: widget.selectedIndex == 0,
                          themeColor: themeColor,
                          onTap: () => widget.onTabSelected(0),
                        ),

                        // 2. Expeditions Matrix / Analytics
                        _LiquidNavItem(
                          icon: Icons.auto_graph_rounded,
                          tooltip: "Expeditions Matrix",
                          isSelected: widget.selectedIndex == 1,
                          themeColor: themeColor,
                          onTap: () => widget.onTabSelected(1),
                        ),

                        // 3. ✨ GEMINI AI INTELLIGENCE HUB
                        if (widget.onOpenGeminiAi != null)
                          GestureDetector(
                            onTap: () {
                              SoundService().playRobotClick();
                              widget.onOpenGeminiAi!();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4285F4), Color(0xFF9B72CB), Color(0xFFD96570)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF9B72CB).withValues(alpha: 0.55),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.white, size: 13),
                                  SizedBox(width: 2),
                                  Text(
                                    "AI",
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // 🔥 4. CENTER REAL ANIMATED BURNING FIRE FLAMES STREAK ORB
                        GestureDetector(
                          onTap: () {
                            SoundService().playVictory();
                            if (widget.onStreakTap != null) {
                              widget.onStreakTap!();
                            }
                          },
                          child: AnimatedBuilder(
                            animation: _flameController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF7C2D12),
                                      Color(0xFFC2410C),
                                      Color(0xFFEA580C),
                                      Color(0xFFFBBF24),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFFDE047),
                                    width: 1.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.8),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFF97316).withValues(
                                        alpha: 0.6 + 0.3 * math.sin(_flameController.value * 2 * math.pi),
                                      ),
                                      blurRadius: 16 + 6 * math.sin(_flameController.value * 2 * math.pi),
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Custom Multi-Layered Flame Particle Animation
                                    SizedBox(
                                      width: 18,
                                      height: 22,
                                      child: CustomPaint(
                                        painter: _BurningFlamePainter(progress: _flameController.value),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${widget.streakDays}D",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            blurRadius: 4,
                                            offset: Offset(1, 1),
                                          ),
                                          Shadow(
                                            color: Color(0xFFEA580C),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // 5. Add Quest Button
                        GestureDetector(
                          onTap: () {
                            SoundService().playVictory();
                            widget.onAddQuest();
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: widget.isFemaleTheme
                                    ? [const Color(0xFFFDE047), const Color(0xFFF59E0B)]
                                    : [const Color(0xFFE9D5FF), const Color(0xFF7E22CE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: themeShadow.withValues(alpha: 0.65),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.7),
                                width: 1.4,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add_rounded,
                                color: widget.isFemaleTheme ? Colors.black : const Color(0xFF1E0836),
                                size: 24,
                              ),
                            ),
                          ),
                        ),

                        // 6. Watch Sync
                        _LiquidNavItem(
                          icon: Icons.watch_rounded,
                          tooltip: "Watch Sync",
                          isSelected: false,
                          themeColor: themeColor,
                          onTap: widget.onOpenWatchSync,
                        ),

                        // 7. Profile / Hunter Status & Settings
                        _LiquidNavItem(
                          icon: Icons.person_rounded,
                          tooltip: "Profile",
                          isSelected: widget.selectedIndex == 3,
                          photoUrl: widget.userPhotoUrl,
                          themeColor: themeColor,
                          onTap: () => widget.onTabSelected(3),
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
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;
  final String? photoUrl;
  final Color themeColor;

  const _LiquidNavItem({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
    this.photoUrl,
    this.themeColor = const Color(0xFFC084FC),
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          SoundService().playClick();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? themeColor.withValues(alpha: 0.22)
                : Colors.transparent,
            border: isSelected
                ? Border.all(color: themeColor, width: 1.4)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.45),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: photoUrl != null
              ? CircleAvatar(
                  radius: 10,
                  backgroundImage: NetworkImage(photoUrl!),
                  backgroundColor: Colors.transparent,
                )
              : Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
        ),
      ),
    );
  }
}

/// Dynamic Multi-Layer Animated Fire Flame CustomPainter
class _BurningFlamePainter extends CustomPainter {
  final double progress;

  _BurningFlamePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h * 0.85);

    final p1 = progress * 2 * math.pi;
    final p2 = (progress + 0.35) * 2 * math.pi;

    // 1. Outer Crimson / Red Flare
    final outerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFEF4444).withValues(alpha: 0.9),
          const Color(0xFFB91C1C).withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w));

    final outerPath = Path();
    outerPath.moveTo(w * 0.15, h * 0.9);
    outerPath.quadraticBezierTo(
      w * 0.05 + math.sin(p1) * 2,
      h * 0.4,
      w * 0.5 + math.sin(p1) * 3,
      h * 0.05 + math.cos(p1) * 2,
    );
    outerPath.quadraticBezierTo(
      w * 0.95 + math.cos(p2) * 2,
      h * 0.4,
      w * 0.85,
      h * 0.9,
    );
    outerPath.close();
    canvas.drawPath(outerPath, outerPaint);

    // 2. Middle Golden / Amber Licking Flame
    final midPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEA580C), Color(0xFFFBBF24)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final midPath = Path();
    midPath.moveTo(w * 0.25, h * 0.85);
    midPath.quadraticBezierTo(
      w * 0.15 + math.cos(p2) * 2,
      h * 0.45,
      w * 0.48 + math.cos(p1) * 2,
      h * 0.18 + math.sin(p2) * 2,
    );
    midPath.quadraticBezierTo(
      w * 0.85 + math.sin(p1) * 2,
      h * 0.45,
      w * 0.75,
      h * 0.85,
    );
    midPath.close();
    canvas.drawPath(midPath, midPaint);

    // 3. Inner White-Hot Core Spark
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final corePath = Path();
    corePath.moveTo(w * 0.35, h * 0.8);
    corePath.quadraticBezierTo(
      w * 0.3,
      h * 0.55,
      w * 0.5 + math.sin(p1) * 1.5,
      h * 0.35 + math.cos(p1) * 1.5,
    );
    corePath.quadraticBezierTo(
      w * 0.7,
      h * 0.55,
      w * 0.65,
      h * 0.8,
    );
    corePath.close();
    canvas.drawPath(corePath, corePaint);
  }

  @override
  bool shouldRepaint(covariant _BurningFlamePainter oldDelegate) => true;
}
