import 'dart:math';

import 'package:coairence/data/models/breath_step.dart';

class BreatheRepository {
  final List<List<BreathStep>> _patterns = [
    [
      (breathTo: 1.0, duration: const Duration(seconds: 5)), // inhale over 5s
      (breathTo: 1.0, duration: const Duration(seconds: 2)), // hold for 2s
      (breathTo: 0.0, duration: const Duration(seconds: 7)), // exhale over 7s
    ],
  ];

  int get selectedPatternIndex => _selectedPatternIndex;
  int _selectedPatternIndex = 0;
  set selectedPatternIndex(int index) {
    _selectedPatternIndex = min(max(index, 0), _patterns.length - 1);
  }

  List<List<BreathStep>> get patterns => _patterns;

  List<BreathStep> get selectedPattern => _patterns[_selectedPatternIndex];
}
