import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';
import '../../services/auth_service.dart';

class ManaCircularRing extends StatelessWidget {
  final double percentage;
  final double size;
  final String label;

  const ManaCircularRing({
    super.key,
    required this.percentage,
    this.size = 130.0,
    this.label = "PROGRESS",
  });

  @override
  Widget build(BuildContext context) {
    final isFemale = context.watch<AuthService>().isFemaleTheme;
    final themeAccent = isFemale ? const Color(0xFFFBBF24) : SoloColors.neonCyan;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ManaRingPainter(percentage: percentage, isFemale: isFemale),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${percentage.toInt()}%",
                style: SoloTypography.monoValue.copyWith(
                  fontSize: size * 0.24,
                  color: isFemale ? const Color(0xFFFDE047) : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                percentage >= 100 ? "CLEARED" : label,
                style: SoloTypography.systemTag.copyWith(
                  fontSize: size * 0.08,
                  color: percentage >= 100 ? SoloColors.rankEmerald : themeAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManaRingPainter extends CustomPainter {
  final double percentage;
  final bool isFemale;

  _ManaRingPainter({required this.percentage, this.isFemale = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = isFemale ? const Color(0xFF1A0E02) : const Color(0xFF07172B)
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Outer tech dashed circle
    final techPaint = Paint()
      ..color = (isFemale ? const Color(0xFFFBBF24) : SoloColors.neonCyan).withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius + 7, techPaint);

    // Animated Mana / Golden Arc
    final sweepAngle = 2 * pi * (percentage.clamp(0, 100) / 100);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final manaPaint = Paint()
      ..shader = SweepGradient(
        colors: isFemale
            ? [const Color(0xFFFBBF24), const Color(0xFFF59E0B), const Color(0xFFEA580C), const Color(0xFFFBBF24)]
            : [SoloColors.neonCyan, SoloColors.manaBlue, SoloColors.manaViolet, SoloColors.neonCyan],
        stops: const [0.0, 0.5, 0.8, 1.0],
        transform: const GradientRotation(-pi / 2),
      ).createShader(rect)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, manaPaint);
  }

  @override
  bool shouldRepaint(covariant _ManaRingPainter oldDelegate) =>
      oldDelegate.percentage != percentage || oldDelegate.isFemale != isFemale;
}
