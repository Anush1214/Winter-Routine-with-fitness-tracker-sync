import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../core/audio/sound_service.dart';

class AriseSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AriseSplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<AriseSplashScreen> createState() => _AriseSplashScreenState();
}

class _AriseSplashScreenState extends State<AriseSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _zoomController;
  late AnimationController _glowController;
  late AnimationController _textFadeController;
  late AnimationController _flashController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _flashAnimation;

  String _statusText = "INITIALIZING SYSTEM PROTOCOL...";
  int _phase = 0;

  @override
  void initState() {
    super.initState();

    // 1. Slow cinematic zoom on Sung Jin-Woo
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeOutCubic),
    );

    // 2. Pulsing Shadow Monarch Aura
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 3. Text and Hologram Fade
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeIn),
    );

    // 4. White flash on awakening transition
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
    );

    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    _zoomController.forward();
    _textFadeController.forward();
    SoundService().playChime();

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _phase = 1;
      _statusText = "[ SYSTEM COMMAND DETECTED ]";
    });
    SoundService().playClick();

    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() {
      _phase = 2;
      _statusText = "COMMAND: 「 A R I S E 」";
    });
    SoundService().playLevelUp();

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _flashController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _glowController.dispose();
    _textFadeController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoloColors.obsidianVoid,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ─── 1. Cinematic Background Image with Slow Zoom ───
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Image.asset(
              'assets/arise_scene.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: SoloColors.obsidianVoid,
                child: const Center(
                  child: Icon(Icons.flash_on, color: SoloColors.neonCyan, size: 80),
                ),
              ),
            ),
          ),

          // ─── 2. Vignette Gradient Overlay ───
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  SoloColors.obsidianVoid.withValues(alpha: 0.7),
                  Colors.transparent,
                  SoloColors.obsidianVoid.withValues(alpha: 0.92),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // ─── 3. Pulsing Shadow Monarch Radial Aura Glow ───
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 0.1),
                    radius: 0.85,
                    colors: [
                      SoloColors.neonCyan.withValues(alpha: _glowAnimation.value * 0.25),
                      SoloColors.manaViolet.withValues(alpha: _glowAnimation.value * 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          // ─── 4. Top System Tag ───
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xAA02050E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: SoloColors.neonCyan.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SoloColors.neonCyan.withValues(alpha: 0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: SoloColors.neonCyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "SOLO LEVELING // SYSTEM LINK",
                        style: SoloTypography.systemTag.copyWith(
                          fontSize: 10,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── 5. Bottom Holographic Awakening Prompt ───
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Holographic Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xCC030A1A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _phase == 2 ? SoloColors.neonCyan : const Color(0x5500F0FF),
                            width: _phase == 2 ? 2.0 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _phase == 2
                                  ? SoloColors.neonCyan.withValues(alpha: 0.5)
                                  : const Color(0x2200F0FF),
                              blurRadius: _phase == 2 ? 25 : 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _statusText,
                              textAlign: TextAlign.center,
                              style: SoloTypography.systemTitle.copyWith(
                                fontSize: _phase == 2 ? 22 : 14,
                                color: _phase == 2 ? SoloColors.neonCyan : Colors.white,
                                letterSpacing: _phase == 2 ? 3.0 : 1.2,
                                shadows: [
                                  Shadow(
                                    color: SoloColors.neonCyan,
                                    blurRadius: _phase == 2 ? 20 : 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "HUNTER AWAKENING SEQUENCE: ACTIVE",
                              style: SoloTypography.bodyMuted.copyWith(
                                fontSize: 10,
                                color: SoloColors.electricSky,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          backgroundColor: const Color(0xFF0F172A),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _phase == 2 ? SoloColors.neonCyan : SoloColors.manaViolet,
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── 6. Flash White Transition on Completion ───
          AnimatedBuilder(
            animation: _flashAnimation,
            builder: (context, _) {
              if (_flashAnimation.value == 0.0) return const SizedBox.shrink();
              return Container(
                color: Colors.white.withValues(alpha: _flashAnimation.value),
              );
            },
          ),
        ],
      ),
    );
  }
}
