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

  BreathSynthService? _synth;
  BreathPhase _lastPhase = BreathPhase.idle;

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
      _synth = ref.read(breathSynthServiceProvider);

      // Synth should already be started by the page — we just verify
      if (_synth case final BreathSynthService synth) unawaited(synth.start());
    }

    _controller.addListener(_onTick);

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

  void _onTick() {
    if (_synth case final BreathSynthService synth) {
      final breathPct = getCurrentBreathPercentage();
      final progress = getCycleProgress();
      final phase = _detectPhase(progress);

      synth.update(breathPct, phase);

      if (phase != _lastPhase && phase != BreathPhase.idle) {
        unawaited(synth.triggerHaptic(phase));
      }
      _lastPhase = phase;
    }
  }

  BreathPhase _detectPhase(double progress) {
    final steps = widget.pattern.steps;
    if (steps.isEmpty) return BreathPhase.idle;

    final totalMs = cycleDuration.inMilliseconds;
    if (totalMs == 0) return BreathPhase.idle;

    final currentTimeMs = progress * totalMs;
    var elapsed = 0.0;
    var currentStepIndex = 0;

    for (var i = 0; i < steps.length; i++) {
      final stepEnd = elapsed + steps[i].duration.inMilliseconds;
      if (currentTimeMs <= stepEnd) {
        currentStepIndex = i;
        break;
      }
      elapsed = stepEnd;
      if (i == steps.length - 1) {
        currentStepIndex = steps.length - 1;
      }
    }

    final currentStep = steps[currentStepIndex];
    final prevBreathTo = currentStepIndex > 0
        ? steps[currentStepIndex - 1].breathTo
        : 0.0;

    final delta = currentStep.breathTo - prevBreathTo;

    if (delta.abs() < 0.01) {
      return prevBreathTo > 0.5 ? BreathPhase.holdIn : BreathPhase.holdOut;
    } else if (delta > 0) {
      return BreathPhase.inhale;
    } else {
      return BreathPhase.exhale;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
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
