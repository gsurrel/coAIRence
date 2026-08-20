import 'dart:async';

import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/viewmodels/breath_page_provider.dart';
import 'package:coairence/ui/widgets/pattern_card.dart';
import 'package:coairence/ui/widgets/pattern_details_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class BreathesLibraryPage extends ConsumerWidget {
  const BreathesLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(breathPageProvider);
    final patterns = state.patterns;
    final selectedPatternIndex = state.selectedPatternIndex;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        childAspectRatio: 0.45,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final pattern = patterns[index];
        final isSelected = index == selectedPatternIndex;

        return PatternCard(
          pattern: pattern,
          isSelected: isSelected,
          onTap: () {
            ref.read(breathPageProvider.notifier).updateSelectedPattern(index);
          },
          onShowDetails: () => _showDetailsBottomSheet(
            context,
            ref,
            pattern,
            index,
          ),
        );
      },
    );
  }

  void _showDetailsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    BreathingPattern pattern,
    int index,
  ) {
    unawaited(
      showModalBottomSheet(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) => PatternDetailsSheet(
          pattern: pattern,
          onUsePattern: () {
            ref.read(breathPageProvider.notifier).updateSelectedPattern(index);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
