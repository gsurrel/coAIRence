import 'package:flutter/material.dart';

class BreathCountdown extends StatelessWidget {
  const BreathCountdown({
    required this.totalRepetitions,
    required this.getCurrentRepetition,
    super.key,
  });

  final int totalRepetitions;
  final int Function() getCurrentRepetition;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: Durations.long1,
        transitionBuilder:
            (Widget child, Animation<double> animation) =>
                FadeTransition(opacity: animation, child: child),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          key: ValueKey<int>(getCurrentRepetition()),
          child: Text(
            switch (1 + totalRepetitions - getCurrentRepetition()) {
              0 => '',
              final int i => '$i',
            },
            style: TextStyle(
              fontSize: 1000,
              color: Theme.of(context).colorScheme.primary.withAlpha(40),
            ),
          ),
        ),
      ),
    );
  }
}
