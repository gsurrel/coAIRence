import 'package:material_ui/material_ui.dart';

class BreatheButton extends StatelessWidget {
  const BreatheButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      ),
      onPressed: onPressed,
      child: const Text('Breathe', style: TextStyle(fontSize: 34)),
    );
  }
}
