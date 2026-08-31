import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/viewmodels/breath_page_provider.dart';
import 'package:coairence/ui/widgets/breath_guide.dart';
import 'package:coairence/ui/widgets/breath_pattern_backdrop.dart';
import 'package:coairence/ui/widgets/breathe_button.dart';
import 'package:coairence/ui/widgets/exercise_config_controls.dart';
import 'package:coairence/ui/widgets/pattern_info_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

@immutable
class BreathePage extends ConsumerStatefulWidget {
  const BreathePage({super.key});

  @override
  ConsumerState<BreathePage> createState() => _BreathePageState();
}

class _BreathePageState extends ConsumerState<BreathePage> {
  int _repetitions = 5;
  double _speedMultiplier = 1;

  void _updateRepetitions(int value) => setState(() => _repetitions = value);

  void _updateSpeedMultiplier(double value) =>
      setState(() => _speedMultiplier = value);

  @override
  Widget build(BuildContext context) {
    final breathePageState = ref.watch(breathPageProvider);
    final toggleShowButton = ref
        .read(breathPageProvider.notifier)
        .toggleShowButton;
    final pattern = breathePageState.pattern;
    final showButton = breathePageState.showButton;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: showButton
                ? _PreStartOverlay(
                    pattern: pattern,
                    repetitions: _repetitions,
                    onRepetitionsChanged: _updateRepetitions,
                    speedMultiplier: _speedMultiplier,
                    onSpeedMultiplierChanged: _updateSpeedMultiplier,
                    onStart: toggleShowButton,
                  )
                : BreathGuide(
                    pattern: pattern,
                    totalRepetitions: _repetitions,
                    speedMultiplier: _speedMultiplier,
                    onExerciseCompleted: toggleShowButton,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Everything shown before the exercise starts: the pattern shape as a
/// backdrop (rendered identically to how [BreathGuide] renders it during
/// the exercise), the pattern's info (name/goal/badges), the
/// repetitions/speed controls, and the start button. All hidden once the
/// exercise begins.
class _PreStartOverlay extends StatelessWidget {
  const _PreStartOverlay({
    required this.pattern,
    required this.repetitions,
    required this.onRepetitionsChanged,
    required this.speedMultiplier,
    required this.onSpeedMultiplierChanged,
    required this.onStart,
  });

  final BreathingPattern pattern;
  final int repetitions;
  final ValueChanged<int> onRepetitionsChanged;
  final double speedMultiplier;
  final ValueChanged<double> onSpeedMultiplierChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BreathPatternBackdrop(pattern: pattern),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PatternInfoPanel(pattern: pattern),
                const SizedBox(height: 24),
                ExerciseConfigControls(
                  repetitions: repetitions,
                  onRepetitionsChanged: onRepetitionsChanged,
                  speedMultiplier: speedMultiplier,
                  onSpeedMultiplierChanged: onSpeedMultiplierChanged,
                ),
                const SizedBox(height: 24),
                BreatheButton(onPressed: onStart),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
