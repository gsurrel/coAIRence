import 'package:coairence/data/models/breath_step.dart';
import 'package:coairence/data/repositories/breathe_repository.dart';
import 'package:coairence/data/services/breathe_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final startPageProvider = ChangeNotifierProvider<StartPageState>((ref) {
  final repository = BreatheRepository();
  final service = BreatheService(repository);
  return StartPageState(service);
});

class StartPageState extends ChangeNotifier {
  StartPageState(this._service);

  final BreatheService _service;

  bool _showButton = true;
  bool get showButton => _showButton;

  List<List<BreathStep>> get patterns => _service.fetchAllPatterns();
  List<BreathStep> get pattern => _service.fetchSelectedPattern();

  void toggleShowButton() {
    _showButton = !_showButton;
    notifyListeners();
  }

  void updateSelectedPattern(int index) {
    _service.selectedPatternIndex = index;
    notifyListeners();
  }
}
