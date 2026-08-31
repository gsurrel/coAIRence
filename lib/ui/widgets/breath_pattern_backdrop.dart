import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/painters/breath_pattern_painter.dart';
import 'package:material_ui/material_ui.dart';

/// Paints the full-cycle shape of a [BreathingPattern], filling all
/// available space.
///
/// Used both as the backdrop during an active exercise (under the animated
/// curve) and as the preview shown before the exercise starts, so both
/// render identically.
class BreathPatternBackdrop extends StatelessWidget {
  const BreathPatternBackdrop({required this.pattern, super.key});

  final BreathingPattern pattern;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: BreathPatternPainter(context, keys: pattern.keys),
    );
  }
}
