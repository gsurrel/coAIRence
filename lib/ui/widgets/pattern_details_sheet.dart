import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/theme/pattern_tag_style.dart';
import 'package:material_ui/material_ui.dart';

/// Bottom-sheet content showing full details for a [BreathingPattern],
/// with a call to action to select it.
class PatternDetailsSheet extends StatelessWidget {
  const PatternDetailsSheet({
    required this.pattern,
    required this.onUsePattern,
    super.key,
  });

  final BreathingPattern pattern;
  final VoidCallback onUsePattern;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(pattern.icon, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pattern.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            pattern.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Use this pattern'),
              onPressed: onUsePattern,
            ),
          ),
        ],
      ),
    );
  }
}
