import 'package:coairence/data/models/result.dart';
import 'package:coairence/data/services/error_logger.dart';
import 'package:flutter/foundation.dart';

extension SafeExecution on Future<dynamic> {
  /// Converts any throwing future into a non-throwing Result
  static Future<Result<T>> safe<T>(Future<T> Function() fn) async {
    try {
      return Success(await fn());
    }
    // General catch because all repos will use it.
    // ignore: avoid_catches_without_on_clauses
    catch (e, st) {
      // Log to console for immediate debugging
      debugPrint('Safe execution failed: $e');

      // Persist to SharedPreferences for later analysis
      await ErrorLogger.log(e, st);

      return Failure(e, st);
    }
  }
}
