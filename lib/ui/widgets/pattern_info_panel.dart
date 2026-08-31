import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/theme/pattern_tag_style.dart';
import 'package:coairence/ui/widgets/breath_mode_legend.dart';
import 'package:material_ui/material_ui.dart';

/// Shows the selected pattern's name, description, difficulty, and tags.
///
/// Meant to be displayed before the exercise starts and hidden once it
/// begins.
class PatternInfoPanel extends StatelessWidget {
  const PatternInfoPanel({required this.pattern, super.key});

  final BreathingPattern pattern;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(pattern.icon, color: theme.colorScheme.primary, size: 32),
        const SizedBox(height: 12),
        Text(
          pattern.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          pattern.description,
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
