import 'dart:math';

import 'package:flutter/material.dart';

class BreathCurve extends StatelessWidget {
  const BreathCurve({
    required this.cycleProgress,
    required this.breathPercent,
    super.key,
  });

  final double cycleProgress;
  final double breathPercent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _BreathPainter(
        context,
        cycleProgress: cycleProgress,
        breathPercent: breathPercent,
      ),
    );
  }
}

class _BreathPainter extends CustomPainter {
  _BreathPainter(
    BuildContext context, {
    required this.cycleProgress,
    required this.breathPercent,
  }) : _paintFill =
           Paint()
             ..color = Theme.of(context).colorScheme.primary.withAlpha(150),
       _paintBorder =
           Paint()
             ..color = Theme.of(context).colorScheme.primary
             ..strokeWidth = 2.0
             ..strokeCap = StrokeCap.round
             ..style = PaintingStyle.stroke;

  final double breathPercent;
  final double cycleProgress;
  final Paint _paintFill;
  final Paint _paintBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final offset = centerX * breathPercent;
    final height = cycleProgress * size.height;
    final lipSize = 2 * sqrt(offset);

    // Draw the path on the canvas
    final path =
        Path()
          // Move to the starting point of the left bracket
          ..moveTo(centerX - offset, height)
          // Draw the top lip
          ..quadraticBezierTo(
            centerX,
            height - lipSize,
            centerX + offset,
            height,
          )
          // Draw the bottom lip
          ..quadraticBezierTo(
            centerX,
            height + lipSize,
            centerX - offset,
            height,
          )
          ..close();

    canvas
      ..drawPath(path, _paintFill)
      ..drawPath(path, _paintBorder);
  }

  @override
  bool shouldRepaint(_BreathPainter oldDelegate) =>
      oldDelegate.cycleProgress != cycleProgress;
}
