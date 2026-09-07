import 'package:coairence/data/models/pattern_tag.dart';
import 'package:material_ui/material_ui.dart';

/// Theme-aware presentation for [PatternTag]s (icon + colors), shared by any
/// widget that renders tag chips.
extension PatternTagStyle on PatternTag {
  IconData get icon => switch (this) {
    PatternTag.calming => Icons.self_improvement,
    PatternTag.sleep => Icons.bedtime,
    PatternTag.hrv => Icons.favorite,
    PatternTag.energy => Icons.bolt,
    PatternTag.focus => Icons.psychology,
    PatternTag.pranayama => Icons.temple_buddhist,
    PatternTag.acute => Icons.flare,
  };

  /// Background color for a chip representing this tag.
  Color color(ColorScheme colorScheme) => switch (this) {
    PatternTag.calming => colorScheme.primaryContainer,
    PatternTag.sleep => colorScheme.tertiaryContainer,
    PatternTag.hrv => colorScheme.errorContainer,
    PatternTag.energy => colorScheme.secondaryContainer,
    PatternTag.focus => colorScheme.primaryContainer,
    PatternTag.pranayama => colorScheme.primaryContainer,
    PatternTag.acute => colorScheme.tertiaryContainer,
  };

  /// Foreground (text/icon) color to pair with [color].
  Color onColor(ColorScheme colorScheme) => switch (this) {
    PatternTag.calming => colorScheme.onPrimaryContainer,
    PatternTag.sleep => colorScheme.onTertiaryContainer,
    PatternTag.hrv => colorScheme.onErrorContainer,
    PatternTag.energy => colorScheme.onSecondaryContainer,
    PatternTag.focus => colorScheme.onPrimaryContainer,
    PatternTag.pranayama => colorScheme.onPrimaryContainer,
    PatternTag.acute => colorScheme.onTertiaryContainer,
  };
}
