import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoogleLogo extends StatelessWidget {
  final double size;
  final bool transparent;

  const GoogleLogo({
    super.key,
    this.size = 20.0,
    this.transparent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: transparent
          ? null
          : const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
      padding: EdgeInsets.all(transparent ? 0.0 : size * 0.15),
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}


class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final double strokeWidth = size.width * 0.28;
    final double innerRadius = r - strokeWidth / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final rect = Rect.fromCircle(center: Offset(r, r), radius: innerRadius);

    // Red segment (Top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -math.pi * 0.85, math.pi * 0.4, false, paint);

    // Yellow segment (Left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -math.pi * 1.35, math.pi * 0.5, false, paint);

    // Green segment (Bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, math.pi * 0.15, math.pi * 0.65, false, paint);

    // Blue segment (Right arc)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -math.pi * 0.45, math.pi * 0.6, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(r, r - strokeWidth / 2, r * 0.95, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
