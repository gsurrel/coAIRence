import 'package:coairence/data/models/achievement.dart';
import 'package:material_ui/material_ui.dart';

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({required this.progress, super.key});

  final AchievementProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final definition = progress.definition;

    final badgeColor = progress.unlocked
        ? definition.color
        : theme.colorScheme.outline;

    final borderColor = progress.unlocked
        ? definition.color.withValues(alpha: 0.6)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.5);

    return Tooltip(
      message:
          '${definition.description}\nProgress: ${progress.current}/${definition.target}',
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceTint.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(definition.icon, color: badgeColor, size: 30),
            Text(
              definition.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge,
            ),
            SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: progress.progress,
                color: definition.color,
                backgroundColor: theme.colorScheme.surfaceTint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
