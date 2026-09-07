import 'package:coairence/data/models/breath_step.dart';
import 'package:coairence/data/models/pattern_tag.dart';
import 'package:coairence/data/models/source.dart';
import 'package:flutter/material.dart';

class BreathingPattern {
  BreathingPattern({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.detailedDescription,
    required this.steps,
    required this.mechanism,
    required this.scientificBasis,
    required this.sources,
    this.tags = const [],
    this.icon = Icons.air,
    this.accentColor,
    this.benefits = const [],
    this.contraindications = const [],
    this.tips = const [],
    this.recommendedDuration = const Duration(minutes: 5),
  }) : assert(
         steps.isNotEmpty,
         'A breathing pattern must have at least one step.',
       ),
       _precalculated = _PrecalculatedData(steps);

  final String id;
  final String name;
  final String shortDescription;
  final String detailedDescription;
  final List<BreathStep> steps;
  final String mechanism;
  final String scientificBasis;
  final List<Source> sources;

  final List<PatternTag> tags;
  final IconData icon;
  final Color? accentColor;

  final List<String> benefits;
  final List<String> contraindications;
  final List<String> tips;
  final Duration recommendedDuration;

  final _PrecalculatedData _precalculated;

  Duration get totalDuration => _precalculated.totalDuration;
  List<({double percentage, double time})> get keys => _precalculated.keys;

  bool get hasSpecialBreathModes =>
      steps.any((step) => step.mode != BreathMode.nose);

  double getBreathPercentage(double progress) {
    final keys = _precalculated.keys;
    if (keys.isEmpty) return 0;

    var index = 0;
    while (index < keys.length - 1 && progress > keys[index + 1].time) {
      index++;
    }
    if (index >= keys.length - 1) return keys.last.percentage;

    final t1 = keys[index].time;
    final t2 = keys[index + 1].time;
    final v1 = keys[index].percentage;
    final v2 = keys[index + 1].percentage;

    if (t2 == t1) return v2;

    var localProgress = (progress - t1) / (t2 - t1);
    localProgress = Curves.easeInOut.transform(localProgress);

    return v1 + (v2 - v1) * localProgress;
  }

  BreathMode getBreathMode(double progress) {
    final modeKeys = _precalculated.modeKeys;
    if (modeKeys.isEmpty) return BreathMode.nose;

    for (final key in modeKeys) {
      if (progress <= key.time) return key.mode;
    }
    return modeKeys.last.mode;
  }

  BreathPhase getBreathPhase(double progress) {
    if (steps.isEmpty) return BreathPhase.idle;

    final totalMs = totalDuration.inMilliseconds;
    if (totalMs == 0) return BreathPhase.idle;

    final currentTimeMs = progress * totalMs;
    double elapsed = 0;
    var currentLevel = 0.0;

    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final stepEnd = elapsed + step.duration.inMilliseconds;

      if (currentTimeMs <= stepEnd) {
        final delta = step.breathTo - currentLevel;
        if (delta.abs() < 0.01) {
          return currentLevel > 0.5 ? BreathPhase.holdIn : BreathPhase.holdOut;
        } else if (delta > 0) {
          return BreathPhase.inhale;
        } else {
          return BreathPhase.exhale;
        }
      }

      currentLevel = step.breathTo;
      elapsed = stepEnd;
    }

    return BreathPhase.idle;
  }
}

class _PrecalculatedData {
  _PrecalculatedData(List<BreathStep> steps)
    : totalDuration = _calculateTotalDuration(steps),
      keys = _calculateKeys(steps),
      modeKeys = _calculateModeKeys(steps);

  final Duration totalDuration;
  final List<({double percentage, double time})> keys;
  final List<({BreathMode mode, double time})> modeKeys;

  static Duration _calculateTotalDuration(List<BreathStep> steps) {
    var total = Duration.zero;
    for (final step in steps) {
      total += step.duration;
    }
    return total;
  }

  static List<({double percentage, double time})> _calculateKeys(
    List<BreathStep> steps,
  ) {
    final keys = <({double percentage, double time})>[];
    var currentTime = Duration.zero;

    keys.add((percentage: 0, time: 0));

    for (final step in steps) {
      currentTime += step.duration;
      final timeSeconds = currentTime.inMilliseconds / 1000.0;
      keys.add((percentage: step.breathTo, time: timeSeconds));
    }

    final totalSeconds = currentTime.inMilliseconds / 1000.0;
    if (totalSeconds <= 0) return [];

    return keys
        .map((k) => (percentage: k.percentage, time: k.time / totalSeconds))
        .toList();
  }

  static List<({BreathMode mode, double time})> _calculateModeKeys(
    List<BreathStep> steps,
  ) {
    final modeKeys = <({BreathMode mode, double time})>[];
    var currentTime = Duration.zero;

    for (final step in steps) {
      currentTime += step.duration;
      final timeSeconds = currentTime.inMilliseconds / 1000.0;
      modeKeys.add((mode: step.mode, time: timeSeconds));
    }

    final totalSeconds = currentTime.inMilliseconds / 1000.0;
    if (totalSeconds <= 0) return [];

    return modeKeys
        .map((k) => (mode: k.mode, time: k.time / totalSeconds))
        .toList();
  }
}
