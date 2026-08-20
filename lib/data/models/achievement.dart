import 'package:material_ui/material_ui.dart';

enum AchievementMetric {
  totalSessions,
  totalMinutes,
  totalCycles,
  longestStreak,
  distinctPatterns,
  morningSessions,
  distinctWeeks,
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.metric,
    required this.target,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementMetric metric;
  final int target;
  final Color color;
}

class UnlockedAchievement {
  const UnlockedAchievement({
    required this.id,
    required this.unlockedAt,
  });

  final String id;
  final DateTime unlockedAt;
}

class AchievementProgress {
  const AchievementProgress({
    required this.definition,
    required this.current,
    required this.unlocked,
    this.unlockedAt,
  });

  final AchievementDefinition definition;
  final int current;
  final bool unlocked;
  final DateTime? unlockedAt;

  double get progress {
    if (definition.target <= 0) return 1;

    final value = current / definition.target;
    if (value < 0) return 0;
    if (value > 1) return 1;

    return value;
  }
}

class AchievementDefinitions {
  static const List<AchievementDefinition> all = [
    AchievementDefinition(
      id: 'first_breath',
      title: 'First Breath',
      description: 'Complete your first session.',
      icon: Icons.air,
      metric: AchievementMetric.totalSessions,
      target: 1,
      color: Colors.teal,
    ),
    AchievementDefinition(
      id: 'warming_up',
      title: 'Warming Up',
      description: 'Complete 5 sessions.',
      icon: Icons.whatshot,
      metric: AchievementMetric.totalSessions,
      target: 5,
      color: Colors.orange,
    ),
    AchievementDefinition(
      id: 'regular',
      title: 'Regular',
      description: 'Complete 10 sessions.',
      icon: Icons.trending_up,
      metric: AchievementMetric.totalSessions,
      target: 10,
      color: Colors.blue,
    ),
    AchievementDefinition(
      id: 'committed',
      title: 'Committed',
      description: 'Complete 25 sessions.',
      icon: Icons.verified,
      metric: AchievementMetric.totalSessions,
      target: 25,
      color: Colors.indigo,
    ),
    AchievementDefinition(
      id: 'dedicated',
      title: 'Dedicated',
      description: 'Complete 50 sessions.',
      icon: Icons.star,
      metric: AchievementMetric.totalSessions,
      target: 50,
      color: Colors.amber,
    ),
    AchievementDefinition(
      id: 'centurion',
      title: 'Centurion',
      description: 'Complete 100 sessions.',
      icon: Icons.emoji_events,
      metric: AchievementMetric.totalSessions,
      target: 100,
      color: Colors.deepOrange,
    ),
    AchievementDefinition(
      id: 'one_hour',
      title: 'One Hour',
      description: 'Breathe for a total of 60 minutes.',
      icon: Icons.timer,
      metric: AchievementMetric.totalMinutes,
      target: 60,
      color: Colors.cyan,
    ),
    AchievementDefinition(
      id: 'deep_diver',
      title: 'Deep Diver',
      description: 'Breathe for a total of 5 hours.',
      icon: Icons.hourglass_bottom,
      metric: AchievementMetric.totalMinutes,
      target: 300,
      color: Colors.lightBlue,
    ),
    AchievementDefinition(
      id: 'hundred_cycles',
      title: '100 Cycles',
      description: 'Complete 100 breathing cycles.',
      icon: Icons.loop,
      metric: AchievementMetric.totalCycles,
      target: 100,
      color: Colors.green,
    ),
    AchievementDefinition(
      id: 'five_hundred_cycles',
      title: '500 Cycles',
      description: 'Complete 500 breathing cycles.',
      icon: Icons.all_inclusive,
      metric: AchievementMetric.totalCycles,
      target: 500,
      color: Colors.teal,
    ),
    AchievementDefinition(
      id: 'three_day_streak',
      title: 'Kindling',
      description: 'Reach a 3-day streak.',
      icon: Icons.local_fire_department,
      metric: AchievementMetric.longestStreak,
      target: 3,
      color: Colors.orange,
    ),
    AchievementDefinition(
      id: 'seven_day_streak',
      title: 'One Week',
      description: 'Reach a 7-day streak.',
      icon: Icons.date_range,
      metric: AchievementMetric.longestStreak,
      target: 7,
      color: Colors.deepOrange,
    ),
    AchievementDefinition(
      id: 'fourteen_day_streak',
      title: 'Two Weeks',
      description: 'Reach a 14-day streak.',
      icon: Icons.calendar_today,
      metric: AchievementMetric.longestStreak,
      target: 14,
      color: Colors.red,
    ),
    AchievementDefinition(
      id: 'thirty_day_streak',
      title: 'One Month',
      description: 'Reach a 30-day streak.',
      icon: Icons.workspace_premium,
      metric: AchievementMetric.longestStreak,
      target: 30,
      color: Colors.purple,
    ),
    AchievementDefinition(
      id: 'explorer',
      title: 'Explorer',
      description: 'Practice 3 different breathing patterns.',
      icon: Icons.explore,
      metric: AchievementMetric.distinctPatterns,
      target: 3,
      color: Colors.lime,
    ),
    AchievementDefinition(
      id: 'pattern_master',
      title: 'Pattern Master',
      description: 'Practice 7 different breathing patterns.',
      icon: Icons.library_books,
      metric: AchievementMetric.distinctPatterns,
      target: 7,
      color: Colors.yellow,
    ),
    AchievementDefinition(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Complete 10 sessions before 9 AM.',
      icon: Icons.wb_twilight,
      metric: AchievementMetric.morningSessions,
      target: 10,
      color: Colors.amberAccent,
    ),
    AchievementDefinition(
      id: 'consistent_practitioner',
      title: 'Consistent Practitioner',
      description: 'Practice in 5 different calendar weeks.',
      icon: Icons.calendar_month,
      metric: AchievementMetric.distinctWeeks,
      target: 5,
      color: Colors.deepPurple,
    ),
  ];
}
