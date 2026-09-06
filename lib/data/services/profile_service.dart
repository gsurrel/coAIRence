import 'package:coairence/data/models/achievement.dart';
import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/models/exercise_session.dart';
import 'package:coairence/data/models/user_stats.dart';
import 'package:coairence/data/repositories/profile_repository.dart';

class ProfileService {
  ProfileService(this._repository);

  final ProfileRepository _repository;

  DateTime _dateOnly(DateTime dateTime) =>
      DateTime.utc(dateTime.year, dateTime.month, dateTime.day);

  int _calculateCurrentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    if (dates[0] != today && dates[0] != yesterday) return 0;

    var streak = 1;

    for (var i = 0; i < dates.length - 1; i++) {
      final difference = dates[i].difference(dates[i + 1]).inDays;

      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Maps an [AchievementMetric] to its current value using pre-fetched data.
  /// [distinctPatterns] is now sourced from the same aggregate query as other
  /// session-based metrics, avoiding a separate DB round-trip.
  int _achievementMetricValue(
    AchievementMetric metric,
    UserStats stats,
    int distinctPatterns,
  ) => switch (metric) {
    AchievementMetric.totalSessions => stats.totalSessions,
    AchievementMetric.totalMinutes => stats.totalMinutes,
    AchievementMetric.totalCycles => stats.totalCycles,
    AchievementMetric.longestStreak => stats.longestStreak,
    AchievementMetric.distinctPatterns => distinctPatterns,
    AchievementMetric.morningSessions => stats.morningSessions,
    AchievementMetric.distinctWeeks => stats.distinctWeeks,
  };

  /// Logs a new exercise session and returns any newly unlocked achievements.
  ///
  /// [patternId] is the stable identifier from [BreathingPattern.id],
  /// replacing the previous name-based lookup.
  Future<List<AchievementDefinition>> logSession({
    required String patternId,
    required Duration duration,
    required int cyclesCompleted,
  }) async {
    final now = DateTime.now();

    final session = ExerciseSession(
      patternId: patternId,
      timestamp: now,
      durationSeconds: duration.inSeconds,
      cyclesCompleted: cyclesCompleted,
      localHour: now.hour,
    );

    await _repository.insertSession(session);

    final dates = await _repository.getDistinctDates();
    final currentStreak = _calculateCurrentStreak(dates);
    final savedLongestStreak = await _repository.getLongestStreak();

    if (currentStreak > savedLongestStreak) {
      await _repository.updateLongestStreak(currentStreak);
    }

    return _evaluateAndUnlockAchievements();
  }

  Future<UserStats> getStats() async {
    final aggregates = await _repository.getAggregateStats();
    final dates = await _repository.getDistinctDates();
    final longestStreak = await _repository.getLongestStreak();
    final currentStreak = _calculateCurrentStreak(dates);

    return UserStats(
      totalSessions: (aggregates['totalSessions'] as int?) ?? 0,
      totalMinutes: ((aggregates['totalDurationSeconds'] as int?) ?? 0) ~/ 60,
      totalCycles: (aggregates['totalCycles'] as int?) ?? 0,
      morningSessions: (aggregates['morningSessions'] as int?) ?? 0,
      distinctWeeks: (aggregates['distinctWeeks'] as int?) ?? 0,
      distinctPatterns: (aggregates['distinctPatterns'] as int?) ?? 0,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }

  Future<List<ExerciseSession>> getHistory() => _repository.getRecentSessions();

  /// Returns the stable ID of the most frequently practiced pattern
  /// in recent sessions. The caller should resolve this to a display name
  /// via the pattern catalog.
  Future<String?> getMostUsedPatternId() async {
    final sessions = await _repository.getRecentSessions(limit: 12);
    if (sessions.isEmpty) return null;

    final counts = <String, int>{};
    for (final session in sessions) {
      counts[session.patternId] = (counts[session.patternId] ?? 0) + 1;
    }

    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Future<List<AchievementProgress>> getAchievements() async {
    // Single call now provides all session-based metrics including
    // distinctPatterns — no separate getDistinctPatternCount() needed.
    final stats = await getStats();
    final unlocked = await _repository.getUnlockedAchievements();

    return AchievementDefinitions.all.map((definition) {
      final current = _achievementMetricValue(
        definition.metric,
        stats,
        stats.distinctPatterns,
      );

      return AchievementProgress(
        definition: definition,
        current: current,
        unlocked: unlocked.containsKey(definition.id),
        unlockedAt: unlocked[definition.id],
      );
    }).toList();
  }

  Future<void> clearData() => _repository.clearAllData();

  Future<List<AchievementDefinition>> _evaluateAndUnlockAchievements() async {
    final stats = await getStats();
    final unlocked = await _repository.getUnlockedAchievements();

    final newlyUnlocked = <AchievementDefinition>[];

    for (final definition in AchievementDefinitions.all) {
      if (unlocked.containsKey(definition.id)) continue;

      final current = _achievementMetricValue(
        definition.metric,
        stats,
        stats.distinctPatterns,
      );

      if (current >= definition.target) {
        newlyUnlocked.add(definition);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await _repository.unlockAchievements(
        newlyUnlocked.map((achievement) => achievement.id).toList(),
      );
    }

    return newlyUnlocked;
  }
}
