import 'dart:async';

import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/services/breath_synth_service.dart';
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
  BreathSynthService? _synth;

  @override
  void initState() {
    super.initState();
    _synth = ref.read(breathSynthServiceProvider);
    unawaited(_synth?.initialize());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(breathPageProvider);
    final notifier = ref.read(breathPageProvider.notifier);
    final pattern = state.selectedPattern;
    final showButton = state.showButton;
    final repetitions = state.repetitions;
    final speedMultiplier = state.speedMultiplier;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: showButton
                ? _PreStartOverlay(
                    key: const ValueKey('pre-start'),
                    pattern: pattern,
                    repetitions: repetitions,
                    onRepetitionsChanged: notifier.setRepetitions,
                    speedMultiplier: speedMultiplier,
                    onSpeedMultiplierChanged: notifier.setSpeedMultiplier,
                    onStart: () {
                      unawaited(_synth?.start());
                      notifier.toggleShowButton();
                    },
                  )
                : BreathGuide(
                    key: const ValueKey('exercise'),
                    pattern: pattern,
                    totalRepetitions: repetitions,
                    speedMultiplier: speedMultiplier,
                    onExerciseCompleted: () async {
                      final messenger = ScaffoldMessenger.of(context);

                      await _synth?.stop();

                      final newlyUnlocked = await notifier.completeExercise();

                      if (newlyUnlocked.isNotEmpty) {
                        final message = newlyUnlocked.length == 1
                            ? 'Achievement unlocked: ${newlyUnlocked.first.title}'
                            : '${newlyUnlocked.length} achievements unlocked: '
                                  '${newlyUnlocked.map((achievement) => achievement.title).join(', ')}';

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(message),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _PreStartOverlay extends StatelessWidget {
  const _PreStartOverlay({
    required this.pattern,
    required this.repetitions,
    required this.onRepetitionsChanged,
    required this.speedMultiplier,
    required this.onSpeedMultiplierChanged,
    required this.onStart,
    super.key,
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
              spacing: 24,
              children: [
                PatternInfoPanel(pattern: pattern),
                ExerciseConfigControls(
                  repetitions: repetitions,
                  onRepetitionsChanged: onRepetitionsChanged,
                  speedMultiplier: speedMultiplier,
                  onSpeedMultiplierChanged: onSpeedMultiplierChanged,
                ),
                BreatheButton(onPressed: onStart),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
