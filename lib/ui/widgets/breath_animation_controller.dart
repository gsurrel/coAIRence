import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:flutter/material.dart';

class BreathAnimationController extends StatefulWidget {
  const BreathAnimationController({
    required this.pattern,
    required this.totalRepetitions,
    required this.onExerciseCompleted,
    required this.child,
    super.key,
  });

  final BreathingPattern pattern;
  final int totalRepetitions;
  final VoidCallback onExerciseCompleted;
  final Widget Function(
    BuildContext,
    double Function() getCycleProgress,
    double Function() getCurrentBreathPercentage,
    int Function() getCurrentRepetition,
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
    totalDuration = cycleDuration * widget.totalRepetitions;

    _controller = AnimationController(vsync: this, duration: totalDuration)
      ..addListener(() => setState(() {}));
    _controller.forward().whenComplete(() {
      if (getCurrentRepetition() >= widget.totalRepetitions) {
        _controller.stop();
        widget.onExerciseCompleted();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double getCycleProgress() =>
      (_controller.value * widget.totalRepetitions) % 1.0;

  double getCurrentBreathPercentage() =>
      widget.pattern.getBreathPercentage(getCycleProgress());

  int getCurrentRepetition() =>
      (_controller.value * widget.totalRepetitions).floor() + 1;

  @override
  Widget build(BuildContext context) {
    print('Rebuilt $BreathAnimationController!');
    return widget.child(
      context,
      getCycleProgress,
      getCurrentBreathPercentage,
      getCurrentRepetition,
    );
  }
}
