import 'package:coairence/data/models/achievement.dart';
import 'package:coairence/data/models/exercise_session.dart';
import 'package:coairence/data/models/user_stats.dart';
import 'package:coairence/ui/viewmodels/data_providers.dart';
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
    final statsAsync = ref.watch(statsProvider);
    final historyAsync = ref.watch(sessionsProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return switch ((statsAsync, historyAsync, achievementsAsync)) {
      (
        AsyncData(value: final UserStats stats),
        AsyncData(value: final List<ExerciseSession> history),
        AsyncData(value: final List<AchievementProgress> achievements),
      ) =>
        _buildContent(
          context,
          ref,
          stats,
          history,
          achievements,
        ),
      _ => const Center(child: CircularProgressIndicator.adaptive()),
    };
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserStats stats,
    List<ExerciseSession> history,
    List<AchievementProgress> achievements,
  ) {
    final theme = Theme.of(context);
    final unlockedCount = achievements.where((a) => a.unlocked).length;

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
                        value: '${stats.currentStreak} days',
                        color: Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: StatCard(
                        icon: Icons.emoji_events,
                        label: 'Longest Streak',
                        value: '${stats.longestStreak} days',
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
                        value: '${stats.totalSessions}',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: StatCard(
                        icon: Icons.timer,
                        label: 'Total Minutes',
                        value: '${stats.totalMinutes}',
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
                      '$unlockedCount/${achievements.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StretchingWrap(
                  minItemWidth: 84,
                  children: achievements
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
                      onPressed: () async {
                        await ref.read(profileServiceProvider).clearData();
                        ref
                          ..invalidate(sessionsProvider)
                          ..invalidate(statsProvider)
                          ..invalidate(achievementsProvider)
                          ..invalidate(mostUsedPatternNameProvider);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (history.isEmpty)
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
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final session = history[index];
                return SessionHistoryItem(session: session);
              },
              childCount: history.length,
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}
