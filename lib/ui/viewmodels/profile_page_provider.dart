import 'dart:async';

import 'package:coairence/data/models/achievement.dart';
import 'package:coairence/data/models/exercise_session.dart';
import 'package:coairence/data/models/user_stats.dart';
import 'package:coairence/data/repositories/profile_repository.dart';
import 'package:coairence/data/services/profile_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(ProfileRepository()),
);

class ProfilePageState {
  const ProfilePageState({
    this.stats = const UserStats(),
    this.history = const [],
    this.achievements = const [],
    this.isLoading = true,
  });

  final UserStats stats;
  final List<ExerciseSession> history;
  final List<AchievementProgress> achievements;
  final bool isLoading;

  ProfilePageState copyWith({
    UserStats? stats,
    List<ExerciseSession>? history,
    List<AchievementProgress>? achievements,
    bool? isLoading,
  }) => ProfilePageState(
    stats: stats ?? this.stats,
    history: history ?? this.history,
    achievements: achievements ?? this.achievements,
    isLoading: isLoading ?? this.isLoading,
  );
}

final profilePageProvider =
    NotifierProvider<ProfilePageNotifier, ProfilePageState>(
      ProfilePageNotifier.new,
    );

class ProfilePageNotifier extends Notifier<ProfilePageState> {
  ProfileService get _service => ref.read(profileServiceProvider);

  @override
  ProfilePageState build() {
    unawaited(_loadData());
    return const ProfilePageState();
  }

  Future<void> _loadData() async {
    final stats = await _service.getStats();
    final history = await _service.getHistory();
    final achievements = await _service.getAchievements();

    state = state.copyWith(
      stats: stats,
      history: history,
      achievements: achievements,
      isLoading: false,
    );
  }

  Future<void> refresh() => _loadData();

  Future<void> clearAllData() async {
    state = state.copyWith(isLoading: true);
    await _service.clearData();
    await _loadData();
  }
}
