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
    this.isPreview = false,
    super.key,
  });

  final BreathingPattern pattern;
  final int totalRepetitions;
  final VoidCallback onExerciseCompleted;
  final double speedMultiplier;

  /// When true, the guide runs the visual animation only, without
  /// initializing audio synthesis or haptics. Used for library card previews.
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(child: BreathPatternBackdrop(pattern: pattern)),
        BreathAnimationController(
          pattern: pattern,
          totalRepetitions: totalRepetitions,
          onExerciseCompleted: onExerciseCompleted,
          speedMultiplier: speedMultiplier,
          audioEnabled: !isPreview,
          child:
              (
                context,
                getCycleProgress,
                getCurrentBreathPercentage,
                getCurrentRepetition,
                getCurrentBreathMode,
              ) => Stack(
                children: [
                  RepaintBoundary(
                    child: BreathCurve(
                      cycleProgress: getCycleProgress(),
                      breathPercent: getCurrentBreathPercentage(),
                      mode: getCurrentBreathMode(),
                    ),
                  ),
                  if (!isPreview)
                    RepaintBoundary(
                      child: BreathCountdown(
                        totalRepetitions: totalRepetitions,
                        getCurrentRepetition: getCurrentRepetition,
                      ),
                    ),
                ],
              ),
        ),
      ],
    );
  }
}
