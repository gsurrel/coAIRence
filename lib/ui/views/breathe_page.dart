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
    final startPageState = ref.watch(breathPageProvider);
    final toggleShowButton =
        ref.read(breathPageProvider.notifier).toggleShowButton;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Stack(
          children: [
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child:
                    startPageState.showButton
                        ? Center(
                          child: BreatheButton(onPressed: toggleShowButton),
                        )
                        : BreathGuide(
                          pattern:
                              ref.read(breathPageProvider.notifier).pattern,
                          totalRepetitions: 5,
                          onExerciseCompleted: toggleShowButton,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
