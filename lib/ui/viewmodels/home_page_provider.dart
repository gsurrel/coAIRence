import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/viewmodels/data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePageState {
  const HomePageState({
    required this.lastPattern,
    required this.mostUsedPattern,
    required this.suggestedPattern,
  });

  final BreathingPattern? lastPattern;
  final BreathingPattern? mostUsedPattern;
  final BreathingPattern? suggestedPattern;
}

final homePageProvider = FutureProvider<HomePageState>((ref) async {
  // Await all async dependencies so loading/error propagates correctly
  final sessions = await ref.watch(sessionsProvider.future);
  final mostUsedName = await ref.watch(mostUsedPatternNameProvider.future);
  final patterns = ref.watch(breatheRepositoryProvider).patterns;

  final lastPattern = sessions.isEmpty
      ? null
      : patterns.where((p) => p.name == sessions.first.patternName).firstOrNull;

  final mostUsedPattern = () {
    if (mostUsedName == null) return null;
    final pattern = patterns.where((p) => p.name == mostUsedName).firstOrNull;
    return pattern != lastPattern ? pattern : null;
  }();

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
