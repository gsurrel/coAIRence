import 'package:coairence/ui/views/main_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const ProviderScope(child: CoAIRenceApp()));

class CoAIRenceApp extends StatelessWidget {
  const CoAIRenceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'coAIRence',
    theme: ThemeData(
      colorSchemeSeed: Colors.purple,
      brightness: Brightness.dark,
    ),
    home: const MainScaffold(),
  );
}
