import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/viewmodels/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePageState {
  const HomePageState({
    this.lastPattern,
    this.mostUsedPattern,
    this.suggestedPattern,
  });

  final BreathingPattern? lastPattern;
  final BreathingPattern? mostUsedPattern;
  final BreathingPattern? suggestedPattern;
}

final homePageProvider = Provider<HomePageState>((ref) {
  final patterns = ref.watch(breatheRepositoryProvider).patterns;

  final lastPattern = ref
      .watch(sessionsProvider)
      .maybeWhen(
        data: (sessions) {
          if (sessions.isEmpty) return null;
          return patterns
              .where((p) => p.name == sessions.first.patternName)
              .firstOrNull;
        },
        orElse: () => null,
      );

  final mostUsedPattern = ref
      .watch(mostUsedPatternNameProvider)
      .maybeWhen(
        data: (name) {
          if (name == null) return null;
          final pattern = patterns.where((p) => p.name == name).firstOrNull;
          // Deduplicate: don't show if same as last
          return pattern != lastPattern ? pattern : null;
        },
        orElse: () => null,
      );

  final suggestedPattern = () {
    final candidate = switch (DateTime.now().hour) {
      < 10 =>
        patterns.where((p) => p.tags.contains(PatternTag.energy)).firstOrNull,
      >= 21 || < 5 =>
        patterns.where((p) => p.tags.contains(PatternTag.sleep)).firstOrNull ??
            patterns
                .where((p) => p.tags.contains(PatternTag.calming))
                .firstOrNull,
      _ =>
        patterns.where((p) => p.tags.contains(PatternTag.hrv)).firstOrNull ??
            patterns
                .where((p) => p.tags.contains(PatternTag.calming))
                .firstOrNull,
    };
    // Deduplicate: don't show if same as last or most used
    if (candidate == lastPattern || candidate == mostUsedPattern) return null;
    return candidate;
  }();

  return HomePageState(
    lastPattern: lastPattern,
    mostUsedPattern: mostUsedPattern,
    suggestedPattern: suggestedPattern,
  );
});
