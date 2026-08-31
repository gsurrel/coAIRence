import 'package:coairence/data/models/achievement.dart';
import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/services/breathe_service.dart';
import 'package:coairence/ui/viewmodels/data_providers.dart';
import 'package:coairence/ui/viewmodels/home_page_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final breatheServiceProvider = Provider<BreatheService>(
  (ref) => BreatheService(ref.watch(breatheRepositoryProvider)),
);

/// Immutable snapshot of the breathe page's state.
class BreathPageState {
  const BreathPageState({
    required this.allPatterns,
    required this.filterTags,
    required this.patterns,
    required this.selectedPattern,
    required this.showButton,
    required this.repetitions,
    required this.speedMultiplier,
  });

  final List<BreathingPattern> allPatterns;
  final List<PatternTag> filterTags;
  final List<BreathingPattern> patterns;
  final BreathingPattern selectedPattern;
  final bool showButton;

  /// How many cycles the next/current exercise should run for.
  final int repetitions;

  /// Playback-speed multiplier applied to the pattern's step durations.
  final double speedMultiplier;

  bool get isExercising => !showButton;

  BreathPageState copyWith({
    List<BreathingPattern>? allPatterns,
    List<PatternTag>? filterTags,
    List<BreathingPattern>? patterns,
    BreathingPattern? pattern,
    bool? showButton,
    int? repetitions,
    double? speedMultiplier,
  }) => BreathPageState(
    allPatterns: allPatterns ?? this.allPatterns,
    filterTags: filterTags ?? this.filterTags,
    patterns: patterns ?? this.patterns,
    selectedPattern: pattern ?? selectedPattern,
    showButton: showButton ?? this.showButton,
    repetitions: repetitions ?? this.repetitions,
    speedMultiplier: speedMultiplier ?? this.speedMultiplier,
  );
}

final breathPageProvider =
    NotifierProvider<BreathPageNotifier, BreathPageState>(
      BreathPageNotifier.new,
    );

class BreathPageNotifier extends Notifier<BreathPageState> {
  BreatheService get _service => ref.read(breatheServiceProvider);

  @override
  BreathPageState build() {
    final allPatterns = _service.fetchAllPatterns();

    // Safely extract lastPattern from the AsyncValue.
    // Returns null if still loading, errored, or genuinely no last pattern.
    final lastPattern = ref.watch(homePageProvider).value?.lastPattern;

    final initialPattern =
        lastPattern != null &&
            allPatterns.any((p) => p.name == lastPattern.name)
        ? lastPattern
        : allPatterns.first;

    return BreathPageState(
      allPatterns: allPatterns,
      filterTags: const [],
      patterns: allPatterns,
      selectedPattern: initialPattern,
      showButton: true,
      repetitions: 5,
      speedMultiplier: 1,
    );
  }

  void toggleShowButton() {
    state = state.copyWith(showButton: !state.showButton);
  }

  /// Select a pattern by identity. Works correctly regardless of current filter.
  void updateSelectedPattern(BreathingPattern pattern) {
    state = state.copyWith(pattern: pattern);
  }

  void setFilterTags(List<PatternTag> tags) {
    final filtered = tags.isEmpty
        ? state.allPatterns
        : state.allPatterns.where((p) => p.tags.any(tags.contains)).toList();

    // Keep the current selection as-is, even if it's no longer in the filtered list.
    state = state.copyWith(filterTags: tags, patterns: filtered);
  }

  void setRepetitions(int value) {
    state = state.copyWith(repetitions: value);
  }

  void setSpeedMultiplier(double value) {
    state = state.copyWith(speedMultiplier: value);
  }

  /// Logs the just-finished exercise, refreshes derived profile data, and
  /// hides the exercise view.
  ///
  /// Returns any achievements newly unlocked by this session, so the caller
  /// can show a notification.
  Future<List<AchievementDefinition>> completeExercise() async {
    final pattern = state.selectedPattern;
    final repetitions = state.repetitions;
    final safeSpeed = state.speedMultiplier > 0 ? state.speedMultiplier : 1.0;

    final profileService = ref.read(profileServiceProvider);
    final newlyUnlocked = await profileService.logSession(
      patternName: pattern.name,
      duration: Duration(
        milliseconds:
            (pattern.totalDuration.inMilliseconds * repetitions / safeSpeed)
                .round(),
      ),
      cyclesCompleted: repetitions,
    );

    ref.invalidateProfileData();
    toggleShowButton();

    return newlyUnlocked;
  }

  /// Aborts the exercise currently in progress, if any, without logging it
  /// to the database, and returns to the pre-start view.
  ///
  /// Does nothing if no exercise is currently running.
  void abortExercise() {
    if (!state.isExercising) return;
    state = state.copyWith(showButton: true);
  }
}
