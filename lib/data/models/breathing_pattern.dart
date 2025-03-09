import 'package:coairence/data/models/breath_step.dart';
import 'package:flutter/widgets.dart';

class BreathingPattern {
  BreathingPattern({
    required this.name,
    required this.description,
    required this.steps,
  }) {
    // Pre-calculate key percentages and times for one cycle.
    final keys = <({double percentage, double time})>[];
    var currentTime = Duration.zero;

    // Start at 0% (center).
    keys.add((percentage: 0, time: 0));
    for (final step in steps) {
      currentTime += step.duration;
      keys.add((
        percentage: step.breathTo,
        time: currentTime.inSeconds.toDouble(),
      ));
    }
    final normalizedKeyTimes =
        keys
            .map(
              (k) => (
                percentage: k.percentage,
                time: k.time / currentTime.inSeconds,
              ),
            )
            .toList();

    _keys = normalizedKeyTimes;
  }

  final String name;
  final String description;
  final List<BreathStep> steps;
  late final List<({double percentage, double time})> _keys;

  List<({double percentage, double time})> get keys => _keys;

  double getBreathPercentage(double progress) {
    var index = 0;
    while (index < _keys.length - 1 && progress > _keys[index + 1].time) {
      index++;
    }
    if (index >= _keys.length - 1) return _keys.last.percentage;

    final t1 = _keys[index].time;
    final t2 = _keys[index + 1].time;
    final v1 = _keys[index].percentage;
    final v2 = _keys[index + 1].percentage;

    var localProgress = (progress - t1) / (t2 - t1);

    localProgress = Curves.easeInOut.transform(localProgress);

    return v1 + (v2 - v1) * localProgress;
  }
}
