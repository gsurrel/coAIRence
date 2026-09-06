import 'package:coairence/data/models/achievement.dart';
import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/models/pattern_tag.dart';
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
    required this.targetDurationMinutes,
    required this.speedMultiplier,
  });

  final List<BreathingPattern> allPatterns;
  final List<PatternTag> filterTags;
  final List<BreathingPattern> patterns;
  final BreathingPattern selectedPattern;
  final bool showButton;

  /// Target exercise duration in minutes (user-selected via slider).
  final int targetDurationMinutes;

  /// Playback-speed multiplier applied to the pattern's step durations.
  final double speedMultiplier;

  bool get isExercising => !showButton;

  /// Derived number of cycles based on target duration, speed, and pattern length.
  /// Always at least 1.
  int get computedRepetitions {
    final cycleMs = selectedPattern.totalDuration.inMilliseconds;
    if (cycleMs <= 0) return 1;

    final effectiveSpeed = speedMultiplier > 0 ? speedMultiplier : 1.0;
    final targetMs = targetDurationMinutes * 60 * 1000;

    // At higher speeds, each cycle takes less real-time, so we fit more cycles.
    // Real time per cycle = cycleMs / effectiveSpeed
    final reps = (targetMs * effectiveSpeed / cycleMs).round();
    return reps < 1 ? 1 : reps;
  }

  BreathPageState copyWith({
    List<BreathingPattern>? allPatterns,
    List<PatternTag>? filterTags,
    List<BreathingPattern>? patterns,
    BreathingPattern? pattern,
    bool? showButton,
    int? targetDurationMinutes,
    double? speedMultiplier,
  }) => BreathPageState(
    allPatterns: allPatterns ?? this.allPatterns,
    filterTags: filterTags ?? this.filterTags,
    patterns: patterns ?? this.patterns,
    selectedPattern: pattern ?? selectedPattern,
    showButton: showButton ?? this.showButton,
    targetDurationMinutes: targetDurationMinutes ?? this.targetDurationMinutes,
    speedMultiplier: speedMultiplier ?? this.speedMultiplier,
  );
}

final breathPageProvider =
    NotifierProvider<BreathPageNotifier, BreathPageState>(
      BreathPageNotifier.new,
    );

class BreathPageNotifier extends Notifier<BreathPageState> {
  BreatheService get _service => ref.read(breatheServiceProvider);

  /// Extracts the recommended duration from a pattern in whole minutes,
  /// clamped to valid slider bounds. Falls back to 5 min if unset or invalid.
  int _durationFromPattern(BreathingPattern pattern) {
    final recommended = pattern.recommendedDuration;
    if (recommended.inMinutes <= 0) return 5;
    return recommended.inMinutes.clamp(2, 30);
  }

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
      targetDurationMinutes: _durationFromPattern(initialPattern),
      speedMultiplier: 1,
    );
  }

  void toggleShowButton() {
    state = state.copyWith(showButton: !state.showButton);
  }

  /// Select a pattern by identity. Works correctly regardless of current filter.
  /// Resets target duration to the new pattern's recommended duration.
  void updateSelectedPattern(BreathingPattern pattern) {
    state = state.copyWith(
      pattern: pattern,
      targetDurationMinutes: _durationFromPattern(pattern),
    );
  }

  void setFilterTags(List<PatternTag> tags) {
    final filtered = tags.isEmpty
        ? state.allPatterns
        : state.allPatterns.where((p) => p.tags.any(tags.contains)).toList();

    // Keep the current selection as-is, even if it's no longer in the filtered list.
    state = state.copyWith(filterTags: tags, patterns: filtered);
  }

  void setTargetDurationMinutes(int value) {
    state = state.copyWith(targetDurationMinutes: value);
  }

  void setSpeedMultiplier(double value) {
    state = state.copyWith(speedMultiplier: value);
  }

  /// Logs the just-finished exercise, refreshes derived profile data, and
  /// hides the exercise view.
  ///
  /// Returns any achievements newly unlocked by this session, so the caller
  /// can show a notification, so it stays out of the notifier.
  Future<List<AchievementDefinition>> completeExercise() async {
    final pattern = state.selectedPattern;
    final repetitions = state.computedRepetitions;
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
