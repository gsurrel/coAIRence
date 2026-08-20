import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/repositories/breathe_repository.dart';

/// Thin access layer over [BreatheRepository].
///
/// Which pattern is currently selected is UI/session state, not something
/// this service tracks — it lives on `BreathPageState` instead (identified
/// by pattern rather than index, so it survives filtering). See
/// breath_page_provider.dart.
class BreatheService {
  BreatheService(this._repository);

  final BreatheRepository _repository;

  List<BreathingPattern> fetchAllPatterns() => _repository.patterns;
}
