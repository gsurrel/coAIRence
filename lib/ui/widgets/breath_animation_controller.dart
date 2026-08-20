import 'dart:async';

import 'package:coairence/data/models/breath_step.dart';
import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BreathAnimationController extends StatefulWidget {
  const BreathAnimationController({
    required this.pattern,
    required this.totalRepetitions,
    required this.onExerciseCompleted,
    required this.child,
    this.speedMultiplier = 1.0,
    super.key,
  });

  final BreathingPattern pattern;
  final int totalRepetitions;
  final VoidCallback onExerciseCompleted;

  /// Scales the pace of the exercise. `1.0` follows the pattern's natural
  /// timing; `> 1.0` runs faster, `< 1.0` runs slower.
  final double speedMultiplier;
  final Widget Function(
    BuildContext,
    double Function() getCycleProgress,
    double Function() getCurrentBreathPercentage,
    int Function() getCurrentRepetition,
    BreathMode Function() getCurrentBreathMode,
  )
  child;

  @override
  State<BreathAnimationController> createState() =>
      _BreathAnimationControllerState();
}

class _BreathAnimationControllerState extends State<BreathAnimationController>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Duration cycleDuration;
  late final Duration totalDuration;

  @override
  void initState() {
    super.initState();
    cycleDuration = widget.pattern.steps.fold<Duration>(
      Duration.zero,
      (prev, step) => prev + step.duration,
    );
    final baseDuration = cycleDuration * widget.totalRepetitions;
    totalDuration = Duration(
      microseconds: (baseDuration.inMicroseconds / widget.speedMultiplier)
          .round(),
    );

    _controller = AnimationController(vsync: this, duration: totalDuration);

    unawaited(WakelockPlus.enable());

    unawaited(
      _controller.forward().whenComplete(() {
        if (getCurrentRepetition() >= widget.totalRepetitions) {
          _controller.stop();
          widget.onExerciseCompleted();
        }
      }),
    );
  }

  @override
  void dispose() {
    unawaited(WakelockPlus.disable());
    _controller.dispose();
    super.dispose();
  }

  double getCycleProgress() =>
      (_controller.value * widget.totalRepetitions) % 1.0;

  double getCurrentBreathPercentage() =>
      widget.pattern.getBreathPercentage(getCycleProgress());

  int getCurrentRepetition() =>
      (_controller.value * widget.totalRepetitions).floor() + 1;

  BreathMode getCurrentBreathMode() =>
      widget.pattern.getBreathMode(getCycleProgress());

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return widget.child(
          context,
          getCycleProgress,
          getCurrentBreathPercentage,
          getCurrentRepetition,
          getCurrentBreathMode,
        );
      },
    );
  }
}
