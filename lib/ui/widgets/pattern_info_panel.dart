import 'dart:async';

import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/theme/pattern_tag_style.dart';
import 'package:coairence/ui/widgets/breath_mode_legend.dart';
import 'package:coairence/ui/widgets/pattern_details_sheet.dart';
import 'package:material_ui/material_ui.dart';

/// Shows the selected pattern's name, description, difficulty, and tags.
///
/// Meant to be displayed before the exercise starts and hidden once it
/// begins.
class PatternInfoPanel extends StatelessWidget {
  const PatternInfoPanel({required this.pattern, super.key});

  final BreathingPattern pattern;

  void _openDetailsSheet(BuildContext context) {
    final scrollController = ScrollController();
    final contraindicationsKey = GlobalKey();

    unawaited(
      showModalBottomSheet<Null>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (_) => PatternDetailsSheet(
          pattern: pattern,
          scrollController: scrollController,
          contraindicationsKey: contraindicationsKey,
          onUsePattern: () => Navigator.of(context).pop(),
        ),
      ).then((_) => scrollController.dispose()),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      final renderBox =
          contraindicationsKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      // Position of the target widget relative to the scrollable viewport
      final targetTop = renderBox.localToGlobal(Offset.zero).dy;

      // Get the scroll view's viewport height
      final viewportHeight = scrollController.position.viewportDimension;
      final targetHeight = renderBox.size.height;

      // Calculate scroll position that centers the widget in the viewport
      // Clamp to valid scroll range to avoid overscroll errors
      final centeredPosition =
          (targetTop + targetHeight / 2 - viewportHeight / 2).clamp(
            0.0,
            scrollController.position.maxScrollExtent,
          );

      scrollController.animateTo(
        centeredPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(pattern.icon, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(pattern.name, style: theme.textTheme.headlineSmall),
            ),
            IconButton(
              icon: pattern.contraindications.isEmpty
                  ? const Icon(Icons.info_outline)
                  : Icon(Icons.error, color: theme.colorScheme.error),
              tooltip: 'Details, benefits & safety notes',
              onPressed: () => _openDetailsSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          pattern.shortDescription,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: pattern.tags
              .map(
                (tag) => Chip(
                  label: Text(tag.name.toUpperCase()),
                  avatar: Icon(tag.icon, size: 16),
                  backgroundColor: tag.color(theme.colorScheme),
                  labelStyle: TextStyle(
                    color: tag.onColor(theme.colorScheme),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              .toList(),
        ),
        if (pattern.hasSpecialBreathModes) ...[
          const SizedBox(height: 20),
          BreathModeLegend(modes: pattern.steps.map((s) => s.mode).toSet()),
        ],
      ],
    );
  }
}
