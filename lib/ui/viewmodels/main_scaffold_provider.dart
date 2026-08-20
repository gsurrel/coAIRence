import 'package:flutter_riverpod/flutter_riverpod.dart';

final mainScaffoldTabProvider = NotifierProvider<MainScaffoldTabNotifier, int>(
  MainScaffoldTabNotifier.new,
);

class MainScaffoldTabNotifier extends Notifier<int> {
  @override
  int build() => 2; // Default to Breathe tab

  set tab(int index) => state = index;
  int get tab => state;
}
