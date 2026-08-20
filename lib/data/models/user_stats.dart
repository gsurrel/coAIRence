class UserStats {
  const UserStats({
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.totalCycles = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.morningSessions = 0,
    this.distinctWeeks = 0,
  });

  final int totalSessions;
  final int totalMinutes;
  final int totalCycles;
  final int currentStreak;
  final int longestStreak;
  final int morningSessions;
  final int distinctWeeks;

  UserStats copyWith({
    int? totalSessions,
    int? totalMinutes,
    int? totalCycles,
    int? currentStreak,
    int? longestStreak,
    int? morningSessions,
    int? distinctWeeks,
  }) => UserStats(
    totalSessions: totalSessions ?? this.totalSessions,
    totalMinutes: totalMinutes ?? this.totalMinutes,
    totalCycles: totalCycles ?? this.totalCycles,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    morningSessions: morningSessions ?? this.morningSessions,
    distinctWeeks: distinctWeeks ?? this.distinctWeeks,
  );
}
