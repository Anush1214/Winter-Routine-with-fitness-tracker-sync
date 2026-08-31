import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';
import '../../core/theme/solo_typography.dart';

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
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ManaRingPainter(percentage: percentage),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${percentage.toInt()}%",
                style: SoloTypography.monoValue.copyWith(
                  fontSize: size * 0.24,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                percentage >= 100 ? "CLEARED" : label,
                style: SoloTypography.systemTag.copyWith(
                  fontSize: size * 0.08,
                  color: percentage >= 100 ? SoloColors.rankEmerald : SoloColors.neonCyan,
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

  _ManaRingPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = const Color(0xFF07172B)
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Outer tech dashed circle
    final techPaint = Paint()
      ..color = SoloColors.neonCyan.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius + 7, techPaint);

    // Animated Mana Arc
    final sweepAngle = 2 * pi * (percentage.clamp(0, 100) / 100);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final manaPaint = Paint()
      ..shader = const SweepGradient(
        colors: [SoloColors.neonCyan, SoloColors.manaBlue, SoloColors.manaViolet, SoloColors.neonCyan],
        stops: [0.0, 0.5, 0.8, 1.0],
        transform: GradientRotation(-pi / 2),
      ).createShader(rect)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, manaPaint);
  }

  @override
  bool shouldRepaint(covariant _ManaRingPainter oldDelegate) =>
      oldDelegate.percentage != percentage;
}
