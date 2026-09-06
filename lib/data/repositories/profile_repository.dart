import 'package:coairence/data/models/achievement.dart';
import 'package:coairence/data/models/exercise_session.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ProfileRepository {
  /// Set to true during development to simulate slow DB/network.
  // ignore: no_literal_bool_comparisons
  static const bool _simulateSlowLoad = kDebugMode && true;

  Database? _database;

  Future<Database> get database async {
    final database = switch (_database) {
      final Database database => database,
      null => await _initDatabase(),
    };

    _database = database;
    return database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'profile.db');

    // Uncomment during active schema development to guarantee a fresh DB
    // if (kDebugMode) {
    //   await deleteDatabase(path);
    // }

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patternId TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL,
        cyclesCompleted INTEGER NOT NULL,
        localHour INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE stats (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        longestStreak INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE unlocked_achievements (
        achievementId TEXT PRIMARY KEY,
        unlockedAt TEXT NOT NULL
      )
    ''');

    // Seed singleton stats row
    await db.insert(
      'stats',
      {'id': 1, 'longestStreak': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  Future<void> insertSession(ExerciseSession session) async {
    final db = await database;
    await db.insert('sessions', session.toMap());
  }

  Future<List<ExerciseSession>> getRecentSessions({int limit = 50}) async {
    if (_simulateSlowLoad) {
      await Future<Null>.delayed(const Duration(seconds: 1));
    }

    final db = await database;
    final maps = await db.rawQuery(
      'SELECT * FROM sessions ORDER BY timestamp DESC LIMIT ?',
      [limit],
    );

    return maps.map(ExerciseSession.fromMap).toList();
  }

  /// Returns all metrics needed by [AchievementMetric] in a single query.
  /// Keys match the SQL aliases consumed by the achievement evaluation layer.
  Future<Map<String, dynamic>> getAggregateStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) AS totalSessions,
        COALESCE(SUM(durationSeconds), 0) AS totalDurationSeconds,
        COALESCE(SUM(cyclesCompleted), 0) AS totalCycles,
        SUM(CASE WHEN localHour BETWEEN 5 AND 8 THEN 1 ELSE 0 END) AS morningSessions,
        COUNT(DISTINCT strftime('%Y-W%W', timestamp)) AS distinctWeeks,
        COUNT(DISTINCT patternId) AS distinctPatterns
      FROM sessions
    ''');

    return result.first;
  }

  Future<List<DateTime>> getDistinctDates({int limit = 365}) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
      SELECT DISTINCT DATE(timestamp) AS dateStr
      FROM sessions
      ORDER BY dateStr DESC
      LIMIT ?
      ''',
      [limit],
    );

    return maps
        .map((m) => DateTime.parse('${m['dateStr']!}T00:00:00Z'))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Stats
  // ---------------------------------------------------------------------------

  Future<int> getLongestStreak() async {
    final db = await database;
    final result = await db.query(
      'stats',
      columns: ['longestStreak'],
      where: 'id = 1',
    );

    if (result.isEmpty) return 0;
    return (result.first['longestStreak'] as int?) ?? 0;
  }

  Future<void> updateLongestStreak(int streak) async {
    final db = await database;
    await db.update('stats', {'longestStreak': streak}, where: 'id = 1');
  }

  // ---------------------------------------------------------------------------
  // Achievements
  // ---------------------------------------------------------------------------

  Future<Map<String, DateTime>> getUnlockedAchievements() async {
    final db = await database;
    final maps = await db.query('unlocked_achievements');

    return {
      for (final map in maps)
        if (map case {
          'achievementId': final String id,
          'unlockedAt': final String unlockedAt,
        })
          id: DateTime.parse(unlockedAt),
    };
  }

  Future<void> unlockAchievements(List<String> achievementIds) async {
    if (achievementIds.isEmpty) return;

    final db = await database;
    final unlockedAt = DateTime.now().toUtc().toIso8601String();

    final batch = db.batch();
    for (final id in achievementIds) {
      batch.insert(
        'unlocked_achievements',
        {'achievementId': id, 'unlockedAt': unlockedAt},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------------------
  // Maintenance
  // ---------------------------------------------------------------------------

  Future<void> clearAllData() async {
    final db = await database;

    await db.transaction<void>((txn) async {
      await txn.delete('sessions');
      await txn.update('stats', {'longestStreak': 0}, where: 'id = 1');
      await txn.delete('unlocked_achievements');
    });
  }
}
