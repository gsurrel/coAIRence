import 'package:coairence/data/models/breath_step.dart';
import 'package:coairence/ui/widgets/breath_curve.dart';
import 'package:material_ui/material_ui.dart';

/// A compact legend explaining the shape-based cues used during the
/// exercise for non-default [BreathMode]s: a filled shape means nose
/// breathing, a split/dimmed fill means one nostril is blocked, and a
/// glowing outline with a hollow center means mouth breathing.
///
/// Meant to be shown once, before the exercise starts, so the live guide
/// itself can stay purely graphical.
class BreathModeLegend extends StatelessWidget {
  const BreathModeLegend({required this.modes, super.key});

  /// Which modes to explain.
  final Set<BreathMode> modes;

  @override
  Widget build(BuildContext context) {
    if (modes.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    // Sort by declaration order so the legend doesn't reshuffle between
    // rebuilds (Set iteration order isn't guaranteed to be stable).
    final sortedModes = modes.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(
          'Shape guide',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 12,
          children: sortedModes
              .map((mode) => _LegendEntry(mode: mode))
              .toList(),
        ),
      ],
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.mode});

  final BreathMode mode;

  String get _label => switch (mode) {
    BreathMode.nose => 'Nose',
    BreathMode.noseLeft => 'Left nostril',
    BreathMode.noseRight => 'Right nostril',
    BreathMode.mouth => 'Mouth',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 36,
          child: BreathCurve(cycleProgress: 0.5, breathPercent: 1, mode: mode),
        ),
        Text(_label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
