import 'package:coairence/data/models/exercise_session.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class ProfileRepository {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'profile.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Strongly typed schema
        await db.execute('''
          CREATE TABLE sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patternName TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            durationSeconds INTEGER NOT NULL,
            cyclesCompleted INTEGER NOT NULL
          )
        ''');

        // Single-row table for persistent aggregates like longest streak
        await db.execute('''
          CREATE TABLE stats (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            longestStreak INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.insert('stats', {'id': 1, 'longestStreak': 0});
      },
    );
  }

  Future<void> insertSession(ExerciseSession session) async {
    final db = await database;
    await db.insert(
      'sessions',
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ExerciseSession>> getRecentSessions({int limit = 50}) async {
    final db = await database;
    // Parameterized query for safety
    final maps = await db.rawQuery(
      'SELECT * FROM sessions ORDER BY timestamp DESC LIMIT ?',
      [limit],
    );
    return maps.map((m) => ExerciseSession.fromMap(m)).toList();
  }

  /// Leverages SQL aggregation to calculate base stats efficiently without
  /// loading all records into Dart memory.
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

  /// Fetches distinct dates to calculate streaks efficiently in Dart.
  /// Uses SQLite's DATE() function to strip the time component.
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

    return maps.map((m) => DateTime.parse(m['dateStr'] as String)).toList();
  }

  Future<int> getLongestStreak() async {
    final db = await database;
    final result = await db.query('stats', where: 'id = 1');
    return result.first['longestStreak'] as int;
  }

  Future<void> updateLongestStreak(int streak) async {
    final db = await database;
    await db.update('stats', {'longestStreak': streak}, where: 'id = 1');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('sessions');
    await db.update('stats', {'longestStreak': 0}, where: 'id = 1');
  }
}
