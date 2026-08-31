import 'package:coairence/data/models/breath_step.dart';
import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:material_ui/material_ui.dart';

class BreatheRepository {
  final List<BreathingPattern> _patterns = [
    // 🧘 CALMING & ANXIETY RELIEF
    BreathingPattern(
      name: 'Box Breathing',
      description: 'Used by Navy SEALs. Equal counts of inhale, hold, exhale, and hold. Great for acute stress.',
      tags: [PatternTag.calming],
      icon: Icons.crop_square,
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 4)),
      ],
    ),
    BreathingPattern(
      name: 'Triangle Breathing',
      description: 'Removes the empty-lung hold of box breathing, making it easier to manage anxiety.',
      tags: [PatternTag.calming],
      icon: Icons.change_history,
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 4)),
      ],
    ),
    BreathingPattern(
      name: '4-7-8 Relaxing Breath',
      description: 'A natural tranquilizer. Extended hold and exhale strongly activate parasympathetic response.',
      tags: [PatternTag.calming, PatternTag.sleep],
      icon: Icons.cloud,
      difficulty: 2,
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 1, duration: const Duration(seconds: 7)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 8)),
      ],
    ),

    // 🌙 SLEEP & DEEP RELAXATION
    BreathingPattern(
      name: 'Deep Sleep (1:2 Ratio)',
      description: 'Prolonged exhale significantly slows heart rate to prepare for sleep.',
      tags: [PatternTag.sleep],
      icon: Icons.nightlight_round,
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 8)),
      ],
    ),
    BreathingPattern(
      name: 'Pursed Lip Breathing',
      description:
          'Keeps airways open longer. Recommended for shortness of breath.',
      tags: [PatternTag.calming],
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(
          breathTo: 0,
          duration: const Duration(seconds: 6),
          mode: BreathMode.mouth,
        ),
      ],
    ),

    // ❤️ HEALTH & HRV OPTIMIZATION
    BreathingPattern(
      name: 'Coherent Breathing',
      description:
          'The gold standard for maximizing Heart Rate Variability (HRV).',
      tags: [PatternTag.hrv, PatternTag.focus],
      icon: Icons.favorite_border,
      difficulty: 2,
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(milliseconds: 5500)),
        BreathStep(breathTo: 0, duration: const Duration(milliseconds: 5500)),
      ],
    ),
    BreathingPattern(
      name: 'Resonant Breathing',
      description: '5 breaths per minute. A slower alternative for deep cardiovascular rest.',
      tags: [PatternTag.hrv, PatternTag.sleep],
      icon: Icons.monitor_heart,
      difficulty: 2,
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 6)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 6)),
      ],
    ),
    BreathingPattern(
      name: 'Physiological Sigh',
      description: 'Double-inhale pops open alveoli, long exhale offloads CO2 to kill stress instantly.',
      tags: [PatternTag.calming, PatternTag.energy],
      icon: Icons.bolt,
      difficulty: 3,
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 3)),
        BreathStep(breathTo: 1, duration: const Duration(seconds: 1)),
        BreathStep(
          breathTo: 0,
          duration: const Duration(seconds: 8),
          mode: BreathMode.mouth,
        ),
      ],
    ),

    // 🧠 ENERGY & FOCUS
    BreathingPattern(
      name: 'Energizing Power Breath',
      description:
          'Fast, rhythmic breathing increases oxygenation and alertness.',
      tags: [PatternTag.energy, PatternTag.focus],
      icon: Icons.flash_on,
      difficulty: 2,
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 2)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 2)),
      ],
    ),
    BreathingPattern(
      name: 'Focus Flow',
      description:
          'Balanced rhythm with subtle pauses for deep work and flow states.',
      tags: [PatternTag.focus],
      icon: Icons.psychology,
      difficulty: 2,
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 5)),
        BreathStep(breathTo: 1, duration: const Duration(seconds: 2)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 5)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 2)),
      ],
    ),
    BreathingPattern(
      name: 'Alternate Nostril Breathing',
      description: 'Yogic Nadi Shodhana. Inhale left, exhale right, inhale right, exhale left.',
      tags: [PatternTag.focus, PatternTag.calming],
      icon: Icons.swap_horiz,
      difficulty: 3,
      steps: [
        BreathStep(
          breathTo: 1,
          duration: const Duration(seconds: 4),
          mode: BreathMode.noseLeft,
        ),
        BreathStep(
          breathTo: 0,
          duration: const Duration(seconds: 4),
          mode: BreathMode.noseRight,
        ),
        BreathStep(
          breathTo: 1,
          duration: const Duration(seconds: 4),
          mode: BreathMode.noseRight,
        ),
        BreathStep(
          breathTo: 0,
          duration: const Duration(seconds: 4),
          mode: BreathMode.noseLeft,
        ),
      ],
    ),
  ];

  // --- HELPER METHODS FOR UI FILTERING ---

  /// Get all unique tags currently in use
  List<PatternTag> get availableTags =>
      _patterns.expand((p) => p.tags).toSet().toList();

  /// Filter patterns by one or more tags
  List<BreathingPattern> getPatternsByTags(List<PatternTag> filterTags) {
    if (filterTags.isEmpty) return _patterns;
    return _patterns
        .where((p) => p.tags.any((t) => filterTags.contains(t)))
        .toList();
  }

  List<BreathingPattern> get patterns => _patterns;
}
