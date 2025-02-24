import 'package:flutter/material.dart';

class BreatheButton extends StatelessWidget {
  const BreatheButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(30),
        ),
        onPressed: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(30),
          child: Text('Breathe', style: TextStyle(fontSize: 34)),
        ),
      ),
    );
  }
}
