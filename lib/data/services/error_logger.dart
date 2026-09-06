import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ErrorLogger {
  static const String _key = 'app_error_log';
  static const int _maxErrors = 10;
  static const Duration _maxAge = Duration(days: 7);

  // Stream to broadcast errors to the UI immediately
  static final _errorController =
      StreamController<Map<String, String>>.broadcast();
  static Stream<Map<String, String>> get errorStream => _errorController.stream;

  // Store the last error for immediate UI access
  static Map<String, String>? _lastError;
  static Map<String, String>? get lastError => _lastError;

  static Future<void> log(Object error, StackTrace stackTrace) async {
    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'error': error.toString(),
      'stackTrace': stackTrace.toString(),
    };

    _lastError = entry; // Update static state
    debugPrint('🚨 ERROR LOGGED: ${entry['error']}');

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentLogs = _pruneStaleEntries(prefs.getStringList(_key) ?? [])
        // Use jsonEncode to handle special characters in stack traces
        ..add(jsonEncode(entry));

      if (currentLogs.length > _maxErrors) {
        currentLogs.removeAt(0);
      }

      await prefs.setStringList(_key, currentLogs);
    }
    // Catch and log all errors happeing.
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      debugPrint('Failed to persist error log: $e');
    }

    // Notify stream listeners only once the persisted store is consistent,
    // so anything that reacts by re-reading storage (e.g. errorLogsProvider)
    // is guaranteed to see this entry.
    _errorController.add(entry);
  }

  static Future<List<Map<String, String>>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final rawLogs = _pruneStaleEntries(prefs.getStringList(_key) ?? []);

    // Decode JSON strings back to Maps. jsonDecode always returns
    // Map<String, dynamic> at runtime, even when every value is a String, so
    // casting the whole map object (`as Map<String, String>`) always throws.
    // Map<String, String>.from copies entry-by-entry instead, which succeeds.
    return rawLogs.map((log) {
      try {
        return Map<String, String>.from(jsonDecode(log) as Map);
      } on FormatException catch (_) {
        return {'error': 'Corrupted log entry', 'timestamp': 'Unknown'};
      }
    }).toList();
  }

  /// Drops raw (still-JSON-encoded) entries older than [_maxAge].
  ///
  /// Called both when persisting a new error and when reading the log, so
  /// entries age out of the display even if no new error ever triggers a
  /// write. An entry whose timestamp can't be parsed is kept rather than
  /// dropped — we can't tell its age, and getLogs() already surfaces
  /// genuinely corrupted entries as "Corrupted log entry" instead of
  /// silently discarding them.
  static List<String> _pruneStaleEntries(List<String> rawLogs) {
    final cutoff = DateTime.now().subtract(_maxAge);

    return rawLogs.where((raw) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final timestamp = DateTime.tryParse(
          decoded['timestamp'] as String? ?? '',
        );
        return timestamp == null || timestamp.isAfter(cutoff);
      } on FormatException catch (_) {
        return true;
      }
    }).toList();
  }
}
