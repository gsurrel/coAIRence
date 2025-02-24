import 'package:coairence/data/models/breath_step.dart';
import 'package:coairence/ui/viewmodels/start_page_provider.dart';
import 'package:coairence/ui/widgets/breath_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class BreathePage extends ConsumerWidget {
  const BreathePage({super.key});

  static const simplePattern = <BreathStep>[
    (breathTo: 1.0, duration: Duration(seconds: 5)), // inhale over 5s
    (breathTo: 1.0, duration: Duration(seconds: 2)), // hold for 2s
    (breathTo: 0.0, duration: Duration(seconds: 7)), // exhale over 7s
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startPageState = ref.watch(startPageProvider);

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
                          key: const ValueKey('startButton'),
                          child: FittedBox(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: const EdgeInsets.all(30),
                              ),
                              onPressed:
                                  () =>
                                      ref
                                          .read(startPageProvider.notifier)
                                          .toggleShowButton(),
                              child: const Padding(
                                padding: EdgeInsets.all(30),
                                child: Text(
                                  'Breathe',
                                  style: TextStyle(fontSize: 34),
                                ),
                              ),
                            ),
                          ),
                        )
                        : BreathGuide(
                          pattern: simplePattern,
                          totalRepetitions: 5,
                          onExerciseCompleted:
                              () =>
                                  ref
                                      .read(startPageProvider.notifier)
                                      .toggleShowButton(),
                          key: const ValueKey('breathingExercise'),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
