import 'dart:math';
import 'package:coairence/data/models/breath_step.dart';
import 'package:coairence/ui/painters/breath_pattern_painter.dart';
import 'package:flutter/material.dart';

class BreathGuide extends StatefulWidget {
  const BreathGuide({
    required this.pattern,
    required this.totalRepetitions,
    required this.onExerciseCompleted,
    super.key,
  });

  final List<BreathStep> pattern;
  final int totalRepetitions;
  final VoidCallback onExerciseCompleted;

  @override
  State<BreathGuide> createState() => _BreathGuideState();
}

class _BreathGuideState extends State<BreathGuide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<double> _keyPercentages;
  late final List<double> _keyTimes; // Normalized time points (0.0 to 1.0)
  late final Duration cycleDuration;
  late final Duration totalDuration;

  @override
  void initState() {
    super.initState();
    cycleDuration = widget.pattern.fold<Duration>(
      Duration.zero,
      (prev, step) => prev + step.duration,
    );
    totalDuration = cycleDuration * widget.totalRepetitions;

    // Pre-calculate key percentages and times for one cycle.
    final percentages = <double>[];
    final times = <double>[];
    double currentTime = 0;

    // Start at 0% (center).
    percentages.add(0);
    times.add(0);
    for (final step in widget.pattern) {
      currentTime += step.duration.inMilliseconds / 1000.0;
      percentages.add(step.breathTo);
      times.add(currentTime);
    }
    final normalizedTimes =
        times.map((t) => t / cycleDuration.inSeconds).toList();

    _keyPercentages = percentages;
    _keyTimes = normalizedTimes;

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

  double getCurrentBreathPercentage() {
    var index = 0;
    while (index < _keyTimes.length - 1 &&
        getCycleProgress() > _keyTimes[index + 1]) {
      index++;
    }
    if (index >= _keyTimes.length - 1) return _keyPercentages.last;

    final t1 = _keyTimes[index];
    final t2 = _keyTimes[index + 1];
    final v1 = _keyPercentages[index];
    final v2 = _keyPercentages[index + 1];

    var localProgress = (getCycleProgress() - t1) / (t2 - t1);

    localProgress = Curves.easeInOut.transform(localProgress);

    return v1 + (v2 - v1) * localProgress;
  }

  int getCurrentRepetition() =>
      (_controller.value * widget.totalRepetitions).floor() + 1;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder:
        (context, constraints) => Stack(
          children: [
            // Backdrop showing the full breathing pattern.
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: BreathPatternPainter(
                context,
                keyPercentages: _keyPercentages,
                keyTimes: _keyTimes,
              ),
            ),
            // The active animation on top.
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _BreathPainter(
                context,
                cycleProgress: getCycleProgress(),
                breathPercent: getCurrentBreathPercentage(),
              ),
            ),
            Center(
              child: AnimatedSwitcher(
                duration: Durations.long1,
                transitionBuilder:
                    (Widget child, Animation<double> animation) =>
                        FadeTransition(opacity: animation, child: child),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  key: ValueKey<int>(getCurrentRepetition()),
                  child: Text(
                    switch (1 +
                        widget.totalRepetitions -
                        getCurrentRepetition()) {
                      0 => '',
                      final int i => '$i',
                    },
                    style: TextStyle(
                      fontSize: 1000,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
  );
}

class _BreathPainter extends CustomPainter {
  _BreathPainter(
    BuildContext context, {
    required this.cycleProgress,
    required this.breathPercent,
  }) : _paintFill =
           Paint()
             ..color = Theme.of(context).colorScheme.primary.withAlpha(150),
       _paintBorder =
           Paint()
             ..color = Theme.of(context).colorScheme.primary
             ..strokeWidth = 2.0
             ..strokeCap = StrokeCap.round
             ..style = PaintingStyle.stroke;

  final double breathPercent;
  final double cycleProgress;
  final Paint _paintFill;
  final Paint _paintBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final offset = centerX * breathPercent;
    final height = cycleProgress * size.height;
    final lipSize = 2 * sqrt(offset);

    // Draw the path on the canvas
    final path =
        Path()
          // Move to the starting point of the left bracket
          ..moveTo(centerX - offset, height)
          // Draw the top lip
          ..quadraticBezierTo(
            centerX,
            height - lipSize,
            centerX + offset,
            height,
          )
          // Draw the bottom lip
          ..quadraticBezierTo(
            centerX,
            height + lipSize,
            centerX - offset,
            height,
          )
          ..close();

    canvas
      ..drawPath(path, _paintFill)
      ..drawPath(path, _paintBorder);
  }

  @override
  bool shouldRepaint(_BreathPainter oldDelegate) =>
      oldDelegate.breathPercent != breathPercent;
}
