import 'package:flutter/material.dart';

class BreathPatternPainter extends CustomPainter {
  BreathPatternPainter(
    BuildContext context, {
    required this.keys,
    this.tension = 0.42,
  }) : _paint =
           Paint()
             ..color = Theme.of(context).colorScheme.onPrimary
             ..strokeWidth = 2.0
             ..style = PaintingStyle.stroke;

  final List<({double percentage, double time})> keys;
  final double tension;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    print('Repainted pattern!');

    // Calculate the center horizontal.
    final centerX = size.width / 2;

    // Create paths for left and right lines.
    final leftPath = _createPath(
      centerX,
      size,
      (centerX, percent) => centerX - centerX * percent,
    );
    final rightPath = _createPath(
      centerX,
      size,
      (centerX, percent) => centerX + centerX * percent,
    );

    // Draw the two paths.
    canvas
      ..drawPath(leftPath, _paint)
      ..drawPath(rightPath, _paint);
  }

  Path _createPath(
    double centerX,
    Size size,
    double Function(double, double) calculateX,
  ) {
    final path = Path()..moveTo(centerX, 0);
    // The keyTimes map to vertical positions along the height.
    for (var i = 0; i < keys.length - 1; i++) {
      final percent = keys[i].percentage;
      final nextPercent = keys[i + 1].percentage;
      final timeFactor = keys[i].time;
      final nextTimeFactor = keys[i + 1].time;

      final x = calculateX(centerX, percent);
      final y = size.height * timeFactor;
      final nextX = calculateX(centerX, nextPercent);
      final nextY = size.height * nextTimeFactor;

      final controlPoint1X = x;
      final controlPoint1Y = y + tension * (nextY - y);
      final controlPoint2X = nextX;
      final controlPoint2Y = nextY - tension * (nextY - y);

      path.cubicTo(
        controlPoint1X,
        controlPoint1Y,
        controlPoint2X,
        controlPoint2Y,
        nextX,
        nextY,
      );
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant BreathPatternPainter oldDelegate) {
    return keys != oldDelegate.keys || tension != oldDelegate.tension;
  }
}
