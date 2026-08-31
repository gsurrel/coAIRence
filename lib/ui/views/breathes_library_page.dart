import 'dart:async';

import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/viewmodels/breath_page_provider.dart';
import 'package:coairence/ui/widgets/pattern_card.dart';
import 'package:coairence/ui/widgets/pattern_details_sheet.dart';
import 'package:flutter_reorderable_grid_view/entities/reorderable_animation_config.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class BreathesLibraryPage extends ConsumerWidget {
  const BreathesLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(breathPageProvider);
    final patterns = state.patterns;
    final selectedPattern = state.selectedPattern;

    return ReorderableBuilder.builder(
      key: const ValueKey('breathes_library_grid'),
      onReorder: (reorderedListFunction) {},
      enableDraggable: false,
      animationConfig: const ReorderableAnimationConfig(
        positionChangeDuration: Duration(milliseconds: 300),
        fadeInDuration: Duration(milliseconds: 250),
        defaultAnimationCurve: Curves.easeInOut,
      ),
      itemCount: patterns.length,
      childBuilder: (itemBuilder) {
        return GridView.builder(
          primary: true,
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 320,
            childAspectRatio: 0.45,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: patterns.length,
          itemBuilder: (context, index) {
            final pattern = patterns[index];
            final isSelected = pattern.name == selectedPattern.name;

            return itemBuilder(
              PatternCard(
                key: ValueKey(pattern.name),
                pattern: pattern,
                isSelected: isSelected,
                onTap: () {
                  ref
                      .read(breathPageProvider.notifier)
                      .updateSelectedPattern(pattern);
                },
                onShowDetails: () =>
                    _showDetailsBottomSheet(context, ref, pattern),
              ),
              index,
            );
          },
        );
      },
    );
  }

  void _showDetailsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    BreathingPattern pattern,
  ) {
    unawaited(
      showModalBottomSheet(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (context) => PatternDetailsSheet(
          pattern: pattern,
          onUsePattern: () {
            ref
                .read(breathPageProvider.notifier)
                .updateSelectedPattern(pattern);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
