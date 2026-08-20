import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/repositories/breathe_repository.dart';
import 'package:coairence/data/services/breathe_service.dart';
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
    required this.pattern,
    required this.selectedPatternIndex,
    required this.showButton,
  });

  final List<BreathingPattern> allPatterns;
  final List<PatternTag> filterTags;
  final List<BreathingPattern> patterns;
  final BreathingPattern pattern;
  final int selectedPatternIndex;
  final bool showButton;

  BreathPageState copyWith({
    List<BreathingPattern>? allPatterns,
    List<PatternTag>? filterTags,
    List<BreathingPattern>? patterns,
    BreathingPattern? pattern,
    int? selectedPatternIndex,
    bool? showButton,
  }) => BreathPageState(
    allPatterns: allPatterns ?? this.allPatterns,
    filterTags: filterTags ?? this.filterTags,
    patterns: patterns ?? this.patterns,
    pattern: pattern ?? this.pattern,
    selectedPatternIndex: selectedPatternIndex ?? this.selectedPatternIndex,
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
    return BreathPageState(
      allPatterns: allPatterns,
      filterTags: const [],
      patterns: allPatterns,
      pattern: _service.fetchSelectedPattern(),
      selectedPatternIndex: _service.selectedPatternIndex,
      showButton: true,
    );
  }

  void toggleShowButton() {
    state = state.copyWith(showButton: !state.showButton);
  }

  void updateSelectedPattern(int index) {
    if (index >= 0 && index < state.patterns.length) {
      state = state.copyWith(
        selectedPatternIndex: index,
        pattern: state.patterns[index],
      );
    }
  }

  void setFilterTags(List<PatternTag> tags) {
    final filtered = tags.isEmpty
        ? state.allPatterns
        : state.allPatterns.where((p) => p.tags.any(tags.contains)).toList();
    state = state.copyWith(
      filterTags: tags,
      patterns: filtered,
      selectedPatternIndex: 0,
      pattern: filtered.isNotEmpty ? filtered.first : state.pattern,
    );
  }
}
