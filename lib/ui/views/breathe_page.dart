import 'package:coairence/ui/viewmodels/breath_page_provider.dart';
import 'package:coairence/ui/widgets/breath_guide.dart';
import 'package:coairence/ui/widgets/breathe_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class BreathePage extends ConsumerWidget {
  const BreathePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breathePageState = ref.watch(breathPageProvider);
    final toggleShowButton = breathePageState.toggleShowButton;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child:
                breathePageState.showButton
                    ? Center(child: BreatheButton(onPressed: toggleShowButton))
                    : BreathGuide(
                      pattern: breathePageState.pattern,
                      totalRepetitions: 5,
                      onExerciseCompleted: toggleShowButton,
                    ),
          ),
        ),
      ),
    );
  }
}
