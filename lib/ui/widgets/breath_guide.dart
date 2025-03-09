import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/painters/breath_pattern_painter.dart';
import 'package:coairence/ui/widgets/breath_animation_controller.dart';
import 'package:coairence/ui/widgets/breath_countdown.dart';
import 'package:coairence/ui/widgets/breath_curve.dart';
import 'package:flutter/material.dart';

class BreathGuide extends StatelessWidget {
  const BreathGuide({
    required this.pattern,
    required this.totalRepetitions,
    required this.onExerciseCompleted,
    super.key,
  });

  final BreathingPattern pattern;
  final int totalRepetitions;
  final VoidCallback onExerciseCompleted;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop showing the full breathing pattern.
        CustomPaint(
          size: Size.infinite,
          painter: BreathPatternPainter(context, keys: pattern.keys),
        ),
        // Animated widgets.
        BreathAnimationController(
          pattern: pattern,
          totalRepetitions: totalRepetitions,
          onExerciseCompleted: onExerciseCompleted,
          child: (
            context,
            getCycleProgress,
            getCurrentBreathPercentage,
            getCurrentRepetition,
          ) {
            return Stack(
              children: [
                // The active animation on top.
                RepaintBoundary(
                  child: BreathCurve(
                    cycleProgress: getCycleProgress(),
                    breathPercent: getCurrentBreathPercentage(),
                  ),
                ),
                // Countdown text.
                BreathCountdown(
                  totalRepetitions: totalRepetitions,
                  getCurrentRepetition: getCurrentRepetition,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
