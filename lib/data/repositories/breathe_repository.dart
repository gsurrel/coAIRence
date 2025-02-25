import 'dart:math';

import 'package:coairence/data/models/breathing_pattern.dart';

class BreatheRepository {
  final List<BreathingPattern> _patterns = [
    (
      name: 'Box Breathing',
      description:
          'Inhale, hold, exhale, and hold again, each for an equal count.',
      steps: [
        (breathTo: 1.0, duration: const Duration(seconds: 4)), // inhale over 4s
        (breathTo: 1.0, duration: const Duration(seconds: 4)), // hold for 4s
        (breathTo: 0.0, duration: const Duration(seconds: 4)), // exhale over 4s
        (breathTo: 0.0, duration: const Duration(seconds: 4)), // hold for 4s
      ],
    ),
    (
      name: '4-7-8 Breathing',
      description:
          'Inhale for 4 seconds, hold for 7 seconds, and exhale for 8 seconds.',
      steps: [
        (breathTo: 1.0, duration: const Duration(seconds: 4)), // inhale over 4s
        (breathTo: 1.0, duration: const Duration(seconds: 7)), // hold for 7s
        (breathTo: 0.0, duration: const Duration(seconds: 8)), // exhale over 8s
      ],
    ),
    (
      name: 'Diaphragmatic Breathing',
      description: 'Deep breaths that engage the diaphragm.',
      steps: [
        (breathTo: 1.0, duration: const Duration(seconds: 5)), // inhale over 5s
        (breathTo: 0.0, duration: const Duration(seconds: 5)), // exhale over 5s
      ],
    ),
    (
      name: 'Alternate Nostril Breathing',
      description:
          'Breathing through one nostril at a time while closing the other '
          'nostril with a finger.',
      steps: [
        (
          breathTo: 1.0,
          duration: const Duration(seconds: 4),
        ), // inhale right nostril over 4s
        (breathTo: 1.0, duration: const Duration(seconds: 4)), // hold for 4s
        (
          breathTo: 0.0,
          duration: const Duration(seconds: 4),
        ), // exhale left nostril over 4s
        (breathTo: 0.0, duration: const Duration(seconds: 4)), // hold for 4s
      ],
    ),
    (
      name: 'Pursed Lip Breathing',
      description:
          'Inhale through the nose and exhale slowly through pursed lips.',
      steps: [
        (breathTo: 1.0, duration: const Duration(seconds: 4)), // inhale over 4s
        (breathTo: 0.0, duration: const Duration(seconds: 6)), // exhale over 6s
      ],
    ),
    (
      name: 'Resonant Breathing',
      description:
          'Breathe at a rate of 5 breaths per minute, with equal time for '
          'inhalation and exhalation.',
      steps: [
        (breathTo: 1.0, duration: const Duration(seconds: 6)), // inhale over 6s
        (breathTo: 0.0, duration: const Duration(seconds: 6)), // exhale over 6s
      ],
    ),
  ];

  int get selectedPatternIndex => _selectedPatternIndex;
  int _selectedPatternIndex = 1;
  set selectedPatternIndex(int index) {
    _selectedPatternIndex = min(max(index, 0), _patterns.length - 1);
  }

  List<BreathingPattern> get patterns => _patterns;

  BreathingPattern get selectedPattern => _patterns[_selectedPatternIndex];
}
