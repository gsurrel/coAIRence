import 'package:coairence/data/models/achievement.dart';
import 'package:coairence/data/models/exercise_session.dart';
import 'package:coairence/data/models/user_stats.dart';
import 'package:coairence/data/repositories/profile_repository.dart';

class ProfileService {
  ProfileService(this._repository);

  final ProfileRepository _repository;

  DateTime _dateOnly(DateTime dateTime) => DateTime.utc(
    dateTime.year,
    dateTime.month,
    dateTime.day,
  );

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
  };

  Future<List<AchievementDefinition>> logSession({
    required String patternName,
    required Duration duration,
    required int cyclesCompleted,
  }) async {
    final session = ExerciseSession(
      patternName: patternName,
      timestamp: DateTime.now(),
      durationSeconds: duration.inSeconds,
      cyclesCompleted: cyclesCompleted,
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
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }

  Future<List<ExerciseSession>> getHistory() => _repository.getRecentSessions();

  Future<List<AchievementProgress>> getAchievements() async {
    final stats = await getStats();
    final distinctPatterns = await _repository.getDistinctPatternCount();
    final unlocked = await _repository.getUnlockedAchievements();

    return AchievementDefinitions.all.map((definition) {
      final current = _achievementMetricValue(
        definition.metric,
        stats,
        distinctPatterns,
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
    final distinctPatterns = await _repository.getDistinctPatternCount();
    final unlocked = await _repository.getUnlockedAchievements();

    final newlyUnlocked = <AchievementDefinition>[];

    for (final definition in AchievementDefinitions.all) {
      if (unlocked.containsKey(definition.id)) continue;

      final current = _achievementMetricValue(
        definition.metric,
        stats,
        distinctPatterns,
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
