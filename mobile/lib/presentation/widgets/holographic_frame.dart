import 'package:flutter/material.dart';
import '../../core/theme/solo_colors.dart';

class HolographicFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hasGlow;
  final double cornerSize;

  const HolographicFrame({
    super.key,
    required this.child,
    this.padding,
    this.hasGlow = true,
    this.cornerSize = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HolographicPainter(
        hasGlow: hasGlow,
        cornerSize: cornerSize,
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: SoloColors.obsidianGlass.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: SoloColors.neonCyan.withOpacity(0.3),
            width: 1.0,
          ),
          boxShadow: hasGlow
              ? [
                  BoxShadow(
                    color: SoloColors.neonCyan.withOpacity(0.12),
                    blurRadius: 20,
                    spreadRadius: -2,
                  ),
                ]
              : [],
        ),
        child: child,
      ),
    );
  }
}

class _HolographicPainter extends CustomPainter {
  final bool hasGlow;
  final double cornerSize;

  _HolographicPainter({required this.hasGlow, required this.cornerSize});

  @override
  void paint(Canvas canvas, Size size) {
    final bracketPaint = Paint()
      ..color = SoloColors.neonCyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Top-Left Corner Bracket
    canvas.drawLine(const Offset(0, 0), Offset(cornerSize, 0), bracketPaint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerSize), bracketPaint);

    // Bottom-Right Corner Bracket
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerSize, size.height),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerSize),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
