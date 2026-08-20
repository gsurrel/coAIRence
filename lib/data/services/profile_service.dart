import 'package:coairence/data/models/exercise_session.dart';
import 'package:coairence/data/models/user_stats.dart';
import 'package:coairence/data/repositories/profile_repository.dart';

class ProfileService {
  ProfileService(this._repository);

  final ProfileRepository _repository;

  int _calculateCurrentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    // Streak is broken if the most recent session wasn't today or yesterday
    if (dates[0] != todayDate && dates[0] != yesterdayDate) return 0;

    var streak = 1;
    for (var i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break; // Streak broken
      }
    }
    return streak;
  }

  Future<void> logSession({
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

    // Recalculate streak and update longest streak if necessary
    final dates = await _repository.getDistinctDates();
    final currentStreak = _calculateCurrentStreak(dates);
    final savedLongest = await _repository.getLongestStreak();

    if (currentStreak > savedLongest) {
      await _repository.updateLongestStreak(currentStreak);
    }
  }

  Future<UserStats> getStats() async {
    final aggregates = await _repository.getAggregateStats();
    final dates = await _repository.getDistinctDates();
    final longestStreak = await _repository.getLongestStreak();
    final currentStreak = _calculateCurrentStreak(dates);

    return UserStats(
      totalSessions: aggregates['totalSessions'] as int,
      totalMinutes: (aggregates['totalDurationSeconds'] as int) ~/ 60,
      totalCycles: aggregates['totalCycles'] as int,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }

  Future<List<ExerciseSession>> getHistory() => _repository.getRecentSessions();

  Future<void> clearData() => _repository.clearAllData();
}
