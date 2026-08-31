import 'package:coairence/data/models/achievement.dart';
import 'package:coairence/data/models/exercise_session.dart';
import 'package:coairence/data/models/user_stats.dart';
import 'package:coairence/data/repositories/breathe_repository.dart';
import 'package:coairence/data/repositories/profile_repository.dart';
import 'package:coairence/data/services/profile_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ref.watch(profileRepositoryProvider)),
);

final breatheRepositoryProvider = Provider<BreatheRepository>(
  (ref) => BreatheRepository(),
);

final sessionsProvider = FutureProvider<List<ExerciseSession>>((ref) async {
  return ref.watch(profileServiceProvider).getHistory();
});

final statsProvider = FutureProvider<UserStats>((ref) async {
  return ref.watch(profileServiceProvider).getStats();
});

final achievementsProvider = FutureProvider<List<AchievementProgress>>((
  ref,
) async {
  return ref.watch(profileServiceProvider).getAchievements();
});

final mostUsedPatternNameProvider = FutureProvider<String?>((ref) async {
  return ref.watch(profileServiceProvider).getMostUsedPatternName();
});

/// Invalidates every provider derived from session/profile data.
///
/// Call this after any write that changes sessions, stats, or achievements
/// (logging a session, clearing history, etc.) so the UI reflects the new
/// state. Centralized here so the four providers can't drift out of sync
/// across call sites.
extension ProfileDataInvalidation on Ref {
  void invalidateProfileData() {
    invalidate(sessionsProvider);
    invalidate(statsProvider);
    invalidate(achievementsProvider);
    invalidate(mostUsedPatternNameProvider);
  }
}
