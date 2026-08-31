import 'package:material_ui/material_ui.dart';

// BreathCountdown's parent (BreathAnimationController) rebuilds its whole
// child subtree on every animation tick (60fps), but the number shown
// here only actually changes once per repetition. Without a guard, that
// meant re-laying-out a fontSize: 1000 Text widget on every single frame
// for no visible benefit. _CountdownDigit below is the part that's
// allowed to skip rebuilding: it's a separate State that only calls
// setState (and therefore only re-lays-out the text) when the displayed
// integer actually changes.
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
      child: _CountdownDigit(
        value: 1 + totalRepetitions - getCurrentRepetition(),
      ),
    );
  }
}

class _CountdownDigit extends StatefulWidget {
  const _CountdownDigit({required this.value});

  final int value;

  @override
  State<_CountdownDigit> createState() => _CountdownDigitState();
}

class _CountdownDigitState extends State<_CountdownDigit> {
  late int _value = widget.value;

  @override
  void didUpdateWidget(_CountdownDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This runs every tick (cheap: an int comparison), but setState below
    // — which is what actually triggers the expensive text re-layout —
    // only fires on the ticks where the shown number really changes.
    if (widget.value != _value) {
      setState(() => _value = widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Durations.long1,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        key: ValueKey<int>(_value),
        child: Text(
          _value == 0 ? '' : '$_value',
          style: TextStyle(
            fontSize: 1000,
            color: Theme.of(context).colorScheme.primary.withAlpha(40),
          ),
        ),
      ),
    );
  }
}
