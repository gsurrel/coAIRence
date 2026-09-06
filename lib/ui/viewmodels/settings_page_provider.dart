import 'package:coairence/data/repositories/safe_execution.dart';
import 'package:coairence/data/services/breath_synth_service.dart';
import 'package:coairence/data/services/error_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// State for app settings.
class SettingsState {
  const SettingsState({
    this.sfxEnabled = true,
    this.hapticsEnabled = true,
    this.volume = 0.5,
  });

  final bool sfxEnabled;
  final bool hapticsEnabled;
  final double volume;

  SettingsState copyWith({
    bool? sfxEnabled,
    bool? hapticsEnabled,
    double? volume,
  }) => SettingsState(
    sfxEnabled: sfxEnabled ?? this.sfxEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    volume: volume ?? this.volume,
  );
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

/// All errors logged so far, from this run and any previous run (persisted
/// via [ErrorLogger]), newest last.
///
/// Also stays live: subscribes to [ErrorLogger.errorStream] and invalidates
/// itself on every new entry, so an error that happens while this page is
/// open shows up without the user having to leave and come back.
final errorLogsProvider = FutureProvider<List<Map<String, String>>>((
  ref,
) async {
  final subscription = ErrorLogger.errorStream.listen((_) {
    ref.invalidateSelf();
  });
  ref.onDispose(subscription.cancel);

  return ErrorLogger.getLogs();
});

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final synthService = ref.read(breathSynthServiceProvider);

    // Use SafeExecution to prevent initialization crashes
    final result = await SafeExecution.safe(synthService.initialize);

    return result.fold(
      onSuccess: (_) {
        final config = synthService.currentConfig;
        return SettingsState(
          sfxEnabled: config.sfxEnabled,
          hapticsEnabled: config.hapticsEnabled,
          volume: config.baseVolume,
        );
      },
      onFailure: (error, stackTrace) {
        // Return a default state even if initialization fails
        debugPrint('Settings init failed, using defaults: $error');
        return const SettingsState();
      },
    );
  }

  /// Centralized helper to update state and persist to service safely
  Future<void> _updateAndPersist(SettingsState newState) async {
    // Optimistic UI update
    state = AsyncData(newState);

    final synthService = ref.read(breathSynthServiceProvider);
    await SafeExecution.safe(
      () => synthService.updateConfig(
        BreathSynthConfig(
          sfxEnabled: newState.sfxEnabled,
          hapticsEnabled: newState.hapticsEnabled,
          baseVolume: newState.volume,
        ),
      ),
    );
  }

  Future<void> setSfxEnabled({required bool enabled}) async {
    final current = state.value ?? const SettingsState();
    await _updateAndPersist(current.copyWith(sfxEnabled: enabled));
  }

  Future<void> setHapticsEnabled({required bool enabled}) async {
    final current = state.value ?? const SettingsState();
    await _updateAndPersist(current.copyWith(hapticsEnabled: enabled));
  }

  Future<void> setVolume(double volume) async {
    final current = state.value ?? const SettingsState();
    await _updateAndPersist(current.copyWith(volume: volume));
  }
}
