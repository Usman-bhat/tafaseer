import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Islamic geometric pattern painter
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  IslamicPatternPainter({
    required this.color,
    this.opacity = 0.05,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw geometric Islamic pattern
    const patternSize = 60.0;
    
    for (double x = 0; x < size.width + patternSize; x += patternSize) {
      for (double y = 0; y < size.height + patternSize; y += patternSize) {
        _drawStarPattern(canvas, Offset(x, y), patternSize / 2, paint);
      }
    }
  }

  void _drawStarPattern(Canvas canvas, Offset center, double radius, Paint paint) {
    // 8-pointed star pattern
    final path = Path();
    const points = 8;
    final innerRadius = radius * 0.4;
    
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    
    // Inner circle
    canvas.drawCircle(center, innerRadius * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget that displays Islamic geometric pattern background
class IslamicPatternBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double opacity;

  const IslamicPatternBackground({
    super.key,
    required this.child,
    required this.isDark,
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Pattern layer
        Positioned.fill(
          child: CustomPaint(
            painter: IslamicPatternPainter(
              color: isDark ? Colors.white : const Color(0xFF1E3A5F),
              opacity: opacity,
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
