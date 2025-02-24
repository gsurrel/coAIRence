import 'package:coairence/data/models/breath_step.dart';
import 'package:coairence/data/repositories/breathe_repository.dart';

class BreatheService {
  BreatheService(this._repository);

  final BreatheRepository _repository;

  List<List<BreathStep>> fetchAllPatterns() => _repository.patterns;

  List<BreathStep> fetchSelectedPattern() => _repository.selectedPattern;

  int get selectedPatternIndex => _repository.selectedPatternIndex;
  set selectedPatternIndex(int index) =>
      _repository.selectedPatternIndex = index;
}
