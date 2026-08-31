import 'dart:async';

import 'package:coairence/ui/viewmodels/profile_page_provider.dart';
import 'package:coairence/ui/widgets/achievement_badge.dart';
import 'package:coairence/ui/widgets/session_history_item.dart';
import 'package:coairence/ui/widgets/stat_card.dart';
import 'package:coairence/ui/widgets/stretching_wrap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilePageProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final theme = Theme.of(context);
    final unlockedCount = state.achievements
        .where((achievement) => achievement.unlocked)
        .length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Journey',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.local_fire_department,
                        label: 'Current Streak',
                        value: '${state.stats.currentStreak} days',
                        color: Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: StatCard(
                        icon: Icons.emoji_events,
                        label: 'Longest Streak',
                        value: '${state.stats.longestStreak} days',
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.self_improvement,
                        label: 'Total Sessions',
                        value: '${state.stats.totalSessions}',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: StatCard(
                        icon: Icons.timer,
                        label: 'Total Minutes',
                        value: '${state.stats.totalMinutes}',
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Achievements',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$unlockedCount/${state.achievements.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StretchingWrap(
                  minItemWidth: 84,
                  children: state.achievements
                      .map(
                        (achievement) =>
                            AchievementBadge(progress: achievement),
                      )
                      .toList(),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Sessions',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Clear'),
                      onPressed: () {
                        unawaited(
                          ref.read(profilePageProvider.notifier).clearAllData(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (state.history.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  Text(
                    'No sessions yet.\nComplete your first exercise!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final session = state.history[index];
              return SessionHistoryItem(session: session);
            }, childCount: state.history.length),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}
