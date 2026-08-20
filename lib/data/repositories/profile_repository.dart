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

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createAchievementsTable(db);
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patternName TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        durationSeconds INTEGER NOT NULL,
        cyclesCompleted INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS stats (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        longestStreak INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await _createAchievementsTable(db);

    await db.insert(
      'stats',
      {'id': 1, 'longestStreak': 0},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> _createAchievementsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS unlocked_achievements (
        achievementId TEXT PRIMARY KEY,
        unlockedAt TEXT NOT NULL
      )
    ''');
  }

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

  Future<Map<String, dynamic>> getAggregateStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as totalSessions,
        COALESCE(SUM(durationSeconds), 0) as totalDurationSeconds,
        COALESCE(SUM(cyclesCompleted), 0) as totalCycles
      FROM sessions
    ''');

    return result.first;
  }

  Future<List<DateTime>> getDistinctDates({int limit = 365}) async {
    final db = await database;
    final maps = await db.rawQuery(
      '''
      SELECT DISTINCT DATE(timestamp) as dateStr
      FROM sessions
      ORDER BY dateStr DESC
      LIMIT ?
    ''',
      [limit],
    );

    return maps
        .map((map) => DateTime.parse('${map['dateStr']}T00:00:00Z'))
        .toList();
  }

  Future<int> getDistinctPatternCount() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT patternName) as patternCount
      FROM sessions
    ''');

    return (result.first['patternCount'] as int?) ?? 0;
  }

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
    await db.update(
      'stats',
      {'longestStreak': streak},
      where: 'id = 1',
    );
  }

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
        {
          'achievementId': id,
          'unlockedAt': unlockedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> clearAllData() async {
    final db = await database;

    await db.transaction<void>((txn) async {
      await txn.delete('sessions');
      await txn.update(
        'stats',
        {'longestStreak': 0},
        where: 'id = 1',
      );
      await txn.delete('unlocked_achievements');
    });
  }
}
