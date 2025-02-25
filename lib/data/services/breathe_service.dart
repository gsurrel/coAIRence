import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/repositories/breathe_repository.dart';

class BreatheService {
  BreatheService(this._repository);

  final BreatheRepository _repository;

  List<BreathingPattern> fetchAllPatterns() => _repository.patterns;

  BreathingPattern fetchSelectedPattern() => _repository.selectedPattern;

  int get selectedPatternIndex => _repository.selectedPatternIndex;
  set selectedPatternIndex(int index) =>
      _repository.selectedPatternIndex = index;
}
