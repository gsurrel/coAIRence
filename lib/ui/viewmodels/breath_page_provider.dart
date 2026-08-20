import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/repositories/breathe_repository.dart';
import 'package:coairence/data/services/breathe_service.dart';
import 'package:coairence/ui/viewmodels/home_page_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final breatheServiceProvider = Provider<BreatheService>(
  (ref) => BreatheService(BreatheRepository()),
);

/// Immutable snapshot of the breathe page's state.
class BreathPageState {
  const BreathPageState({
    required this.allPatterns,
    required this.filterTags,
    required this.patterns,
    required this.selectedPattern,
    required this.showButton,
  });

  final List<BreathingPattern> allPatterns;
  final List<PatternTag> filterTags;
  final List<BreathingPattern> patterns;
  final BreathingPattern selectedPattern;
  final bool showButton;

  BreathPageState copyWith({
    List<BreathingPattern>? allPatterns,
    List<PatternTag>? filterTags,
    List<BreathingPattern>? patterns,
    BreathingPattern? pattern,
    bool? showButton,
  }) => BreathPageState(
    allPatterns: allPatterns ?? this.allPatterns,
    filterTags: filterTags ?? this.filterTags,
    patterns: patterns ?? this.patterns,
    selectedPattern: pattern ?? selectedPattern,
    showButton: showButton ?? this.showButton,
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

    // Use the last exercised pattern from homePageProvider as initial selection.
    // Fall back to first pattern if no exercise history exists.
    final lastPattern = ref.watch(homePageProvider).lastPattern;
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
    state = state.copyWith(
      filterTags: tags,
      patterns: filtered,
    );
  }
}
