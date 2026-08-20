import 'dart:async';

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
    this.isLoading = true,
  });

  final UserStats stats;
  final List<ExerciseSession> history;
  final bool isLoading;

  ProfilePageState copyWith({
    UserStats? stats,
    List<ExerciseSession>? history,
    bool? isLoading,
  }) => ProfilePageState(
    stats: stats ?? this.stats,
    history: history ?? this.history,
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
    state = state.copyWith(stats: stats, history: history, isLoading: false);
  }

  Future<void> refresh() => _loadData();

  Future<void> clearAllData() async {
    await _service.clearData();
    state = const ProfilePageState(isLoading: false);
  }
}
