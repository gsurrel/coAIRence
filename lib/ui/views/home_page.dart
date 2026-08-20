import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/theme/pattern_tag_style.dart';
import 'package:coairence/ui/viewmodels/breath_page_provider.dart';
import 'package:coairence/ui/viewmodels/home_page_provider.dart';
import 'package:coairence/ui/viewmodels/main_scaffold_provider.dart';
import 'package:coairence/ui/widgets/stretching_wrap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Tracks whether the initial entrance animation has completed
  bool _hasEntranceAnimated = false;

  @override
  void initState() {
    super.initState();
    // Trigger animations after the first frame is painted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _hasEntranceAnimated = true);
    });
  }

  void _navigateToBreathe(BreathingPattern pattern) {
    final patterns = ref.read(breathPageProvider).allPatterns;
    if (patterns.any((p) => p.name == pattern.name)) {
      ref.read(breathPageProvider.notifier).setFilterTags(const []);
      ref.read(breathPageProvider.notifier).updateSelectedPattern(pattern);
      ref.read(mainScaffoldTabProvider.notifier).tab = 2;
    }
  }

  void _navigateToLibrary(PatternTag tag) {
    ref.read(breathPageProvider.notifier).setFilterTags([tag]);
    ref.read(mainScaffoldTabProvider.notifier).tab = 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final asyncState = ref.watch(homePageProvider);
    final state = asyncState.value;
    final isLoading = asyncState.isLoading;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: [
                _StaggeredItem(
                  visible: _hasEntranceAnimated,
                  delayMs: 0,
                  child: Text(
                    '👋 ${switch (DateTime.now().hour) {
                      < 12 => 'Good morning',
                      < 17 => 'Good afternoon',
                      _ => 'Good evening',
                    }}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StaggeredItem(
                  visible: _hasEntranceAnimated,
                  delayMs: 150,
                  child: _RecommendationCard(
                    title: 'For right now',
                    subtitle: 'Based on the time of day',
                    pattern: state?.suggestedPattern,
                    isLoading: isLoading,
                    onTap: state?.suggestedPattern != null
                        ? () => _navigateToBreathe(state!.suggestedPattern!)
                        : null,
                  ),
                ),
                _StaggeredItem(
                  visible: _hasEntranceAnimated,
                  delayMs: 250,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.antiAlias,
                    child: _RecommendationCard(
                      title: 'Continue',
                      subtitle: state?.lastPattern != null
                          ? 'You last did ${state!.lastPattern!.name}'
                          : 'Loading your history...',
                      pattern: state?.lastPattern,
                      isLoading: isLoading,
                      onTap: state?.lastPattern != null
                          ? () => _navigateToBreathe(state!.lastPattern!)
                          : null,
                    ),
                  ),
                ),
                _StaggeredItem(
                  visible: _hasEntranceAnimated,
                  delayMs: 350,
                  child: _RecommendationCard(
                    title: 'Your favorite',
                    subtitle: 'Most used in your last 12 sessions',
                    pattern: state?.mostUsedPattern,
                    isLoading: isLoading,
                    onTap: state?.mostUsedPattern != null
                        ? () => _navigateToBreathe(state!.mostUsedPattern!)
                        : null,
                  ),
                ),
                _StaggeredItem(
                  visible: _hasEntranceAnimated,
                  delayMs: 450,
                  child: Text(
                    'Looking for something?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StaggeredItem(
                  visible: _hasEntranceAnimated,
                  delayMs: 550,
                  child: _MoodSelector(onTap: _navigateToLibrary),
                ),
              ],
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

/// A single unified card that handles:
/// 1. Placeholder → real data crossfade (same widget tree)
/// 2. Smooth height transition when content size changes
/// 3. Graceful collapse to zero when pattern becomes permanently null
class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.title,
    required this.subtitle,
    required this.pattern,
    required this.onTap,
    this.isLoading = false,
  });

  final String title;
  final String subtitle;
  final BreathingPattern? pattern;
  final VoidCallback? onTap;
  final bool isLoading; // ← NEW

  bool get _isPlaceholder => isLoading && pattern == null;
  bool get _shouldRender => isLoading || pattern != null; // ← KEY LOGIC

  @override
  Widget build(BuildContext context) {
    // If not loading AND no pattern → don't render at all.
    // AnimatedSize in the PARENT handles the smooth collapse.
    if (!_shouldRender) return const SizedBox.shrink();

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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _isPlaceholder
                        ? Container(
                            key: const ValueKey('placeholder-icon'),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )
                        : Icon(
                            key: ValueKey('real-icon-${pattern!.name}'),
                            pattern!.icon,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
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
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            subtitle,
                            key: ValueKey(subtitle),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _isPlaceholder
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : theme.colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isPlaceholder
                        ? Container(
                            key: const ValueKey('placeholder-play'),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                          )
                        : Icon(
                            key: const ValueKey('real-play'),
                            Icons.play_circle_fill,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isPlaceholder
                    ? Column(
                        key: const ValueKey('placeholder-body'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Container(
                            width: 160,
                            height: 16,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        key: ValueKey('real-body-${pattern!.name}'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            pattern!.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            pattern!.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable staggered slide-up + fade-in wrapper.
/// Animation fires exactly once based on [visible] transitioning false→true.
class _StaggeredItem extends StatefulWidget {
  const _StaggeredItem({
    required this.visible,
    required this.delayMs,
    required this.child,
  });

  final bool visible;
  final int delayMs;
  final Widget child;

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _StaggeredItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _opacityAnimation, child: widget.child),
    );
  }
}

// --- Unchanged helpers below ---

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
            children: [Icon(tag.icon, size: 32), Text(tag.name.capitalize())],
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
