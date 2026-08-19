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
    required this.patterns,
    required this.pattern,
    required this.selectedPatternIndex,
    required this.showButton,
  });

  final List<BreathingPattern> patterns;
  final BreathingPattern pattern;
  final int selectedPatternIndex;
  final bool showButton;

  BreathPageState copyWith({
    List<BreathingPattern>? patterns,
    BreathingPattern? pattern,
    int? selectedPatternIndex,
    bool? showButton,
  }) => BreathPageState(
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
  BreathPageState build() => BreathPageState(
    patterns: _service.fetchAllPatterns(),
    pattern: _service.fetchSelectedPattern(),
    selectedPatternIndex: _service.selectedPatternIndex,
    showButton: true,
  );

  void toggleShowButton() {
    state = state.copyWith(showButton: !state.showButton);
  }

  void updateSelectedPattern(int index) {
    _service.selectedPatternIndex = index;
    state = state.copyWith(
      selectedPatternIndex: _service.selectedPatternIndex,
      pattern: _service.fetchSelectedPattern(),
    );
  }
}
