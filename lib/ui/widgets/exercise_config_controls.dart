import 'package:material_ui/material_ui.dart';

/// Controls for customizing an upcoming breathing exercise: how many
/// repetitions to run and how fast to run them.
///
/// Shown before the exercise starts; hidden once it begins.
/// Sensory feedback (SFX/haptics) settings are managed in the Settings page.
class ExerciseConfigControls extends StatelessWidget {
  const ExerciseConfigControls({
    required this.repetitions,
    required this.onRepetitionsChanged,
    required this.speedMultiplier,
    required this.onSpeedMultiplierChanged,
    super.key,
    this.minRepetitions = 1,
    this.maxRepetitions = 15,
    this.speedSteps = const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
  });

  final int repetitions;
  final ValueChanged<int> onRepetitionsChanged;
  final int minRepetitions;
  final int maxRepetitions;

  final double speedMultiplier;
  final ValueChanged<double> onSpeedMultiplierChanged;
  final List<double> speedSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ConfigRow(
          label: 'Repetitions',
          valueLabel: '$repetitions',
          onDecrement: repetitions > minRepetitions
              ? () => onRepetitionsChanged(repetitions - 1)
              : null,
          onIncrement: repetitions < maxRepetitions
              ? () => onRepetitionsChanged(repetitions + 1)
              : null,
        ),
        const SizedBox(height: 4),
        _ConfigRow(
          label: 'Speed',
          valueLabel: '${_formatSpeed(speedMultiplier)}x',
          onDecrement: _canStepSpeed(-1)
              ? () => onSpeedMultiplierChanged(_stepSpeed(-1))
              : null,
          onIncrement: _canStepSpeed(1)
              ? () => onSpeedMultiplierChanged(_stepSpeed(1))
              : null,
        ),
      ],
    );
  }

  int _currentSpeedIndex() {
    var closestIndex = 0;
    var closestDistance = double.infinity;
    for (var i = 0; i < speedSteps.length; i++) {
      final distance = (speedSteps[i] - speedMultiplier).abs();
      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }
    return closestIndex;
  }

  bool _canStepSpeed(int direction) {
    final nextIndex = _currentSpeedIndex() + direction;
    return nextIndex >= 0 && nextIndex < speedSteps.length;
  }

  double _stepSpeed(int direction) =>
      speedSteps[_currentSpeedIndex() + direction];

  String _formatSpeed(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({
    required this.label,
    required this.valueLabel,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final String valueLabel;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onDecrement,
          visualDensity: VisualDensity.compact,
        ),
        SizedBox(
          width: 55,
          child: Text(
            valueLabel,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onIncrement,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
