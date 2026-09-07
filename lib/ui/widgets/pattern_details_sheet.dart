import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/models/source.dart';
import 'package:coairence/ui/theme/pattern_tag_style.dart';
import 'package:coairence/ui/viewmodels/breath_page_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom-sheet content showing full details for a [BreathingPattern],
/// with a call to action to select it.
class PatternDetailsSheet extends ConsumerWidget {
  const PatternDetailsSheet({
    required this.pattern,
    required this.onUsePattern,
    this.scrollController,
    this.contraindicationsKey,
    super.key,
  });

  final BreathingPattern pattern;
  final VoidCallback onUsePattern;
  final ScrollController? scrollController;
  final GlobalKey? contraindicationsKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(breathPageProvider);
    final selectedPattern = state.selectedPattern;

    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 12,
              children: [
                Icon(
                  pattern.icon,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
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
            const SizedBox(height: 4),
            Text(
              pattern.shortDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            _RecommendedDurationRow(duration: pattern.recommendedDuration),
            const SizedBox(height: 16),
            Text(
              pattern.detailedDescription,
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

            if (pattern.mechanism.isNotEmpty) ...[
              const SizedBox(height: 24),
              const _SectionHeader(
                icon: Icons.settings_suggest_outlined,
                label: 'How it works',
              ),
              const SizedBox(height: 8),
              Text(
                pattern.mechanism,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            if (pattern.scientificBasis.isNotEmpty) ...[
              const SizedBox(height: 24),
              const _SectionHeader(
                icon: Icons.science_outlined,
                label: 'What the research says',
              ),
              const SizedBox(height: 8),
              Text(
                pattern.scientificBasis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            if (pattern.benefits.isNotEmpty) ...[
              const SizedBox(height: 24),
              const _SectionHeader(
                icon: Icons.favorite_border,
                label: 'Benefits',
              ),
              const SizedBox(height: 8),
              _BulletList(
                items: pattern.benefits,
                bulletIcon: Icons.check_circle_outline,
                bulletColor: theme.colorScheme.primary,
              ),
            ],

            if (pattern.tips.isNotEmpty) ...[
              const SizedBox(height: 24),
              const _SectionHeader(
                icon: Icons.lightbulb_outline,
                label: 'Tips',
              ),
              const SizedBox(height: 8),
              _BulletList(
                items: pattern.tips,
                bulletIcon: Icons.arrow_right,
                bulletColor: theme.colorScheme.onSurfaceVariant,
              ),
            ],

            if (pattern.contraindications.isNotEmpty) ...[
              const SizedBox(height: 24),
              _ContraindicationsCard(
                key: contraindicationsKey,
                contraindications: pattern.contraindications,
              ),
            ],

            if (pattern.sources.isNotEmpty) ...[
              const SizedBox(height: 24),
              const _SectionHeader(
                icon: Icons.menu_book_outlined,
                label: 'Sources',
              ),
              const SizedBox(height: 8),
              ...pattern.sources.map((source) => _SourceTile(source: source)),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Use this pattern'),
                onPressed: pattern != selectedPattern ? onUsePattern : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small caption-style header used to introduce each detail section.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: 8,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Renders a list of strings as bulleted rows with a configurable icon.
class _BulletList extends StatelessWidget {
  const _BulletList({
    required this.items,
    required this.bulletIcon,
    required this.bulletColor,
  });

  final List<String> items;
  final IconData bulletIcon;
  final Color bulletColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: items
          .map(
            (item) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(bulletIcon, size: 18, color: bulletColor),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

/// Visually distinct card for safety-relevant contraindications — kept
/// separate from the plain bullet styling used elsewhere so it reads as a
/// caution rather than as just another list of tips.
class _ContraindicationsCard extends StatelessWidget {
  const _ContraindicationsCard({
    required this.contraindications,
    super.key,
  });

  final List<String> contraindications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: errorColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: errorColor),
              Text(
                'Before you begin',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _BulletList(
            items: contraindications,
            bulletIcon: Icons.remove,
            bulletColor: errorColor,
          ),
        ],
      ),
    );
  }
}

/// A single citation row. Author/publication are shown as secondary text;
/// the title stands in for a tappable link.
class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source});

  final Source source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(source.url)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              source.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: theme.colorScheme.primary.withValues(
                  alpha: 0.4,
                ),
              ),
            ),
            Text(
              '${source.author} · ${source.publication}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formats duration as a short pill, e.g. "~5 min".
class _RecommendedDurationRow extends StatelessWidget {
  const _RecommendedDurationRow({required this.duration});

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = duration.inMinutes;
    final label = minutes >= 1 ? '~$minutes min' : '~${duration.inSeconds} sec';

    return Row(
      spacing: 6,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        Text(
          '$label recommended',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
