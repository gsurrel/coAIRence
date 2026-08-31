import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/widgets/breath_animation_controller.dart';
import 'package:coairence/ui/widgets/breath_countdown.dart';
import 'package:coairence/ui/widgets/breath_curve.dart';
import 'package:coairence/ui/widgets/breath_pattern_backdrop.dart';
import 'package:material_ui/material_ui.dart';

class BreathGuide extends StatelessWidget {
  const BreathGuide({
    required this.pattern,
    required this.totalRepetitions,
    required this.onExerciseCompleted,
    this.speedMultiplier = 1.0,
    super.key,
  });

  final BreathingPattern pattern;
  final int totalRepetitions;
  final VoidCallback onExerciseCompleted;
  final double speedMultiplier;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop showing the full breathing pattern.
        BreathPatternBackdrop(pattern: pattern),
        // Animated widgets.
        BreathAnimationController(
          pattern: pattern,
          totalRepetitions: totalRepetitions,
          onExerciseCompleted: onExerciseCompleted,
          speedMultiplier: speedMultiplier,
          child:
              (
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
