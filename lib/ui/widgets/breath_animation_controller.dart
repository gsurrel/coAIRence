import 'dart:async';

import 'package:coairence/data/models/breath_step.dart';
import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/services/breath_synth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BreathAnimationController extends ConsumerStatefulWidget {
  const BreathAnimationController({
    required this.pattern,
    required this.totalRepetitions,
    required this.onExerciseCompleted,
    required this.child,
    this.speedMultiplier = 1.0,
    this.audioEnabled = true,
    super.key,
  });

  final BreathingPattern pattern;
  final int totalRepetitions;
  final VoidCallback onExerciseCompleted;
  final double speedMultiplier;
  final bool audioEnabled;

  final Widget Function(
    BuildContext,
    double Function() getCycleProgress,
    double Function() getCurrentBreathPercentage,
    int Function() getCurrentRepetition,
    BreathMode Function() getCurrentBreathMode,
  )
  child;

  @override
  ConsumerState<BreathAnimationController> createState() =>
      _BreathAnimationControllerState();
}

class _BreathAnimationControllerState
    extends ConsumerState<BreathAnimationController>
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

    if (widget.audioEnabled) {
      unawaited(WakelockPlus.enable());

      // The synth drives its own wall-clock timer for the whole exercise
      // (see BreathSynthService.startCycle) instead of being pushed
      // per-frame from this controller — that keeps sound/haptics running
      // smoothly even if the app is backgrounded and Flutter's animation
      // ticks pause.
      unawaited(
        ref
            .read(breathSynthServiceProvider)
            .startCycle(
              pattern: widget.pattern,
              totalRepetitions: widget.totalRepetitions,
              speedMultiplier: widget.speedMultiplier,
            ),
      );
    }

    unawaited(
      _controller.forward().whenComplete(() async {
        if (getCurrentRepetition() >= widget.totalRepetitions) {
          _controller.stop();
          // Do NOT stop synth here — it persists across exercises
          widget.onExerciseCompleted();
        }
      }),
    );
  }

  @override
  void dispose() {
    // Do NOT stop synth — it persists
    if (widget.audioEnabled) {
      unawaited(WakelockPlus.disable());
    }
    _controller.dispose();
    super.dispose();
  }

  double getCycleProgress() =>
      (_controller.value * widget.totalRepetitions) % 1;

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
