import 'dart:math';

import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/repositories/breathe_repository.dart';

/// Coordinates access to breathing patterns and tracks which one is
/// currently selected.
///
/// The repository itself stays a stateless data source; "which pattern is
/// selected" is application state, not repository data, so it lives here.
class BreatheService {
  BreatheService(this._repository);

  final BreatheRepository _repository;

  int _selectedPatternIndex = 0;

  List<BreathingPattern> fetchAllPatterns() => _repository.patterns;

  BreathingPattern fetchSelectedPattern() =>
      _repository.patterns[_selectedPatternIndex];

  int get selectedPatternIndex => _selectedPatternIndex;

  set selectedPatternIndex(int index) {
    _selectedPatternIndex = min(
      max(index, 0),
      _repository.patterns.length - 1,
    );
  }
}
