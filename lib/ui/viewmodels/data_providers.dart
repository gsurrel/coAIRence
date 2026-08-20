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
