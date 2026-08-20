import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/theme/pattern_tag_style.dart';
import 'package:coairence/ui/widgets/breath_guide.dart';
import 'package:material_ui/material_ui.dart';

/// A selectable card previewing a [BreathingPattern]: name, live preview
/// animation, difficulty, cycle duration, and tags.
class PatternCard extends StatelessWidget {
  const PatternCard({
    required this.pattern,
    required this.isSelected,
    required this.onTap,
    required this.onShowDetails,
    super.key,
  });

  final BreathingPattern pattern;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onShowDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Derive colors directly from the theme for Light/Dark mode compatibility
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    final cardColor = isSelected
        ? theme.colorScheme.surface.withValues(alpha: 0.2)
        : theme.colorScheme.surface.withValues(alpha: 0.6);

    return Card(
      elevation: isSelected ? 4 : 1,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(pattern: pattern, onShowDetails: onShowDetails),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: BreathGuide(
                    pattern: pattern,
                    totalRepetitions: 1,
                    onExerciseCompleted: () {},
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _CardFooter(pattern: pattern),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.pattern});

  final BreathingPattern pattern;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDuration(pattern.totalDuration),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: pattern.tags.map((tag) {
            final tagColor = tag.color(theme.colorScheme);
            final tagOnColor = tag.onColor(theme.colorScheme);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(tag.icon, size: 16, color: tagOnColor),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s cycle';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s cycle';
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.pattern, required this.onShowDetails});

  final BreathingPattern pattern;
  final VoidCallback onShowDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(pattern.icon, color: theme.colorScheme.primary, size: 24),
        _DifficultyIndicator(pattern: pattern),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: onShowDetails,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'Details',
          visualDensity: const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
            vertical: VisualDensity.minimumDensity,
          ),
        ),
      ],
    );
  }
}

class _DifficultyIndicator extends StatelessWidget {
  const _DifficultyIndicator({required this.pattern});

  final BreathingPattern pattern;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Icon(
          index < pattern.difficulty
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          size: 16,
          color: index < pattern.difficulty
              ? theme.colorScheme.tertiary
              : theme.colorScheme.outlineVariant,
        );
      }),
    );
  }
}
