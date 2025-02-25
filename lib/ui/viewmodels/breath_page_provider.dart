import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/repositories/breathe_repository.dart';
import 'package:coairence/data/services/breathe_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final breathPageProvider = ChangeNotifierProvider<BreathPageState>((ref) {
  final repository = BreatheRepository();
  final service = BreatheService(repository);
  return BreathPageState(service);
});

class BreathPageState extends ChangeNotifier {
  BreathPageState(this._service);

  final BreatheService _service;

  bool _showButton = true;
  bool get showButton => _showButton;

  List<BreathingPattern> get patterns => _service.fetchAllPatterns();
  BreathingPattern get pattern => _service.fetchSelectedPattern();
  int get selectedPatternIndex => _service.selectedPatternIndex;

  void toggleShowButton() {
    _showButton = !_showButton;
    notifyListeners();
  }

  void updateSelectedPattern(int index) {
    _service.selectedPatternIndex = index;
    notifyListeners();
  }
}
