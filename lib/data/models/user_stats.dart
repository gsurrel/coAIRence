class UserStats {
  const UserStats({
    required this.currentStreak,
    required this.distinctPatterns,
    required this.distinctWeeks,
    required this.longestStreak,
    required this.morningSessions,
    required this.totalCycles,
    required this.totalMinutes,
    required this.totalSessions,
  });

  final int currentStreak;
  final int distinctPatterns;
  final int distinctWeeks;
  final int longestStreak;
  final int morningSessions;
  final int totalCycles;
  final int totalMinutes;
  final int totalSessions;

  UserStats copyWith({
    int? currentStreak,
    int? distinctPatterns,
    int? distinctWeeks,
    int? longestStreak,
    int? morningSessions,
    int? totalCycles,
    int? totalMinutes,
    int? totalSessions,
  }) => UserStats(
    currentStreak: currentStreak ?? this.currentStreak,
    distinctPatterns: distinctPatterns ?? this.distinctPatterns,
    distinctWeeks: distinctWeeks ?? this.distinctWeeks,
    longestStreak: longestStreak ?? this.longestStreak,
    morningSessions: morningSessions ?? this.morningSessions,
    totalCycles: totalCycles ?? this.totalCycles,
    totalMinutes: totalMinutes ?? this.totalMinutes,
    totalSessions: totalSessions ?? this.totalSessions,
  );
}
