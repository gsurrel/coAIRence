import 'package:coairence/data/models/breath_step.dart';
import 'package:material_ui/material_ui.dart';

enum PatternTag { calming, sleep, hrv, energy, focus }

class BreathingPattern {
  BreathingPattern({
    required this.name,
    required this.description,
    required this.steps,
    this.tags = const [],
    this.icon = Icons.air,
    this.difficulty = 1,
    this.accentColor,
  }) {
    // Pre-calculate key percentages and times for one cycle.
    final keys = <({double percentage, double time})>[];
    // End-time of each step paired with its mode, used to look up which
    // mode is active at a given point in the cycle (see [getBreathMode]).
    final modeKeys = <({BreathMode mode, double time})>[];
    var currentTime = Duration.zero;

    // Start at 0% (center).
    keys.add((percentage: 0, time: 0));
    for (final step in steps) {
      currentTime += step.duration;
      final timeSeconds =
          currentTime.inMilliseconds /
          1000.0; // Use ms for sub-second precision
      keys.add((percentage: step.breathTo, time: timeSeconds));
      modeKeys.add((mode: step.mode, time: timeSeconds));
    }

    _totalDuration = currentTime;

    // Avoid division by zero if steps are empty
    final totalSeconds = currentTime.inMilliseconds / 1000.0;
    final normalizedKeyTimes = totalSeconds > 0
        ? keys
              .map(
                (k) => (percentage: k.percentage, time: k.time / totalSeconds),
              )
              .toList()
        : <({double percentage, double time})>[];
    final normalizedModeKeys = totalSeconds > 0
        ? modeKeys
              .map((k) => (mode: k.mode, time: k.time / totalSeconds))
              .toList()
        : <({BreathMode mode, double time})>[];

    _keys = normalizedKeyTimes;
    _modeKeys = normalizedModeKeys;
  }

  // --- CORE FIELDS ---
  final String name;
  final String description;
  final List<BreathStep> steps;

  // --- METADATA FIELDS ---
  final List<PatternTag> tags;
  final IconData icon;
  final int difficulty; // 1 = Beginner, 2 = Intermediate, 3 = Advanced
  final Color? accentColor;

  // --- ANIMATION & TIMING INTERNALS ---
  late final List<({double percentage, double time})> _keys;
  late final List<({BreathMode mode, double time})> _modeKeys;
  late final Duration _totalDuration;

  List<({double percentage, double time})> get keys => _keys;

  /// Total duration of one complete breathing cycle
  Duration get totalDuration => _totalDuration;

  /// Whether any step in this pattern uses a mode other than
  /// [BreathMode.nose] — i.e. whether it's worth showing mode guidance
  /// for this pattern at all.
  bool get hasSpecialBreathModes =>
      steps.any((step) => step.mode != BreathMode.nose);

  double getBreathPercentage(double progress) {
    if (_keys.isEmpty) return 0;

    var index = 0;
    while (index < _keys.length - 1 && progress > _keys[index + 1].time) {
      index++;
    }
    if (index >= _keys.length - 1) return _keys.last.percentage;

    final t1 = _keys[index].time;
    final t2 = _keys[index + 1].time;
    final v1 = _keys[index].percentage;
    final v2 = _keys[index + 1].percentage;

    // Prevent division by zero if two keys share the same time
    if (t2 == t1) return v2;

    var localProgress = (progress - t1) / (t2 - t1);
    localProgress = Curves.easeInOut.transform(localProgress);

    return v1 + (v2 - v1) * localProgress;
  }

  /// Returns the [BreathMode] active at [progress] (0.0-1.0 through one
  /// cycle).
  ///
  /// Unlike [getBreathPercentage], this is never interpolated between
  /// steps — mode is a discrete choice, not something to blend — so it
  /// simply returns whichever step contains [progress].
  BreathMode getBreathMode(double progress) {
    if (_modeKeys.isEmpty) return BreathMode.nose;

    for (final key in _modeKeys) {
      if (progress <= key.time) return key.mode;
    }
    return _modeKeys.last.mode;
  }
}
