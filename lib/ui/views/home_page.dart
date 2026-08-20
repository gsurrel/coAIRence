import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/theme/pattern_tag_style.dart';
import 'package:coairence/ui/viewmodels/breath_page_provider.dart';
import 'package:coairence/ui/viewmodels/home_page_provider.dart';
import 'package:coairence/ui/viewmodels/main_scaffold_provider.dart';
import 'package:coairence/ui/widgets/stretching_wrap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _navigateToBreathe(WidgetRef ref, BreathingPattern pattern) {
    final patterns = ref.read(breathPageProvider).allPatterns;
    final index = patterns.indexWhere((p) => p.name == pattern.name);
    if (index != -1) {
      ref.read(breathPageProvider.notifier).setFilterTags(const []);
      ref.read(breathPageProvider.notifier).updateSelectedPattern(index);
      ref.read(mainScaffoldTabProvider.notifier).tab = 2;
    }
  }

  void _navigateToLibrary(WidgetRef ref, PatternTag tag) {
    ref.read(breathPageProvider.notifier).setFilterTags([tag]);
    ref.read(mainScaffoldTabProvider.notifier).tab = 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(homePageProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: [
                Text(
                  '👋 ${switch (DateTime.now().hour) {
                    < 12 => 'Good morning',
                    < 17 => 'Good afternoon',
                    _ => 'Good evening',
                  }}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (state.lastPattern case final lastPattern?)
                  _RecommendationCard(
                    title: 'Continue',
                    subtitle: 'You last did ${lastPattern.name}',
                    pattern: lastPattern,
                    onTap: () => _navigateToBreathe(ref, lastPattern),
                  ),

                if (state.mostUsedPattern case final mostUsedPattern?)
                  _RecommendationCard(
                    title: 'Your favorite',
                    subtitle: 'Most used in your last 12 sessions',
                    pattern: mostUsedPattern,
                    onTap: () => _navigateToBreathe(ref, mostUsedPattern),
                  ),

                if (state.suggestedPattern case final suggestedPattern?)
                  _RecommendationCard(
                    title: 'For right now',
                    subtitle: 'Based on the time of day',
                    pattern: suggestedPattern,
                    onTap: () => _navigateToBreathe(ref, suggestedPattern),
                  ),

                Text(
                  'Looking for something?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _MoodSelector(onTap: (tag) => _navigateToLibrary(ref, tag)),
              ],
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.title,
    required this.subtitle,
    required this.pattern,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final BreathingPattern pattern;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Row(
                children: [
                  Icon(
                    pattern.icon,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.play_circle_fill,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              Text(
                pattern.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                pattern.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({required this.onTap});

  final void Function(PatternTag) onTap;

  @override
  Widget build(BuildContext context) {
    return StretchingWrap(
      minItemWidth: 82,
      children: PatternTag.values
          .map((tag) => _MoodChip(tag: tag, onTap: () => onTap(tag)))
          .toList(),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.tag, required this.onTap});

  final PatternTag tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tagColor = tag.color(theme.colorScheme);

    return Material(
      color: tagColor.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: tagColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Icon(tag.icon, size: 32),
              Text(tag.name.capitalize()),
            ],
          ),
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    if (toLowerCase() == 'hrv') return 'HRV';
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
