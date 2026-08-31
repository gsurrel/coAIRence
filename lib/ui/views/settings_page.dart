import 'dart:async';

import 'package:coairence/data/services/breath_synth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// App-wide settings: sensory feedback for breathing exercises.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (e, _) => Center(child: Text('Error loading settings: $e')),
      data: (settings) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            8,
            24,
            8,
            MediaQuery.of(context).padding.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    'Sensory Feedback',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Sound Effects'),
                    subtitle: const Text(
                      'Synthesized ambient tones during breathing',
                    ),
                    value: settings.sfxEnabled,
                    secondary: const Icon(Icons.music_note_rounded),
                    onChanged: (value) {
                      unawaited(
                        ref
                            .read(settingsProvider.notifier)
                            .setSfxEnabled(enabled: value),
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Haptic Feedback'),
                    subtitle: const Text(
                      'Vibration cues at breath phase transitions',
                    ),
                    value: settings.hapticsEnabled,
                    secondary: const Icon(Icons.vibration_rounded),
                    onChanged: (value) {
                      unawaited(
                        ref
                            .read(settingsProvider.notifier)
                            .setHapticsEnabled(enabled: value),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Volume'),
                    subtitle: Slider(
                      value: settings.volume,
                      min: 0.1,
                      divisions: 9,
                      label: '${(settings.volume * 100).round()}%',
                      onChanged: (value) {
                        unawaited(
                          ref.read(settingsProvider.notifier).setVolume(value),
                        );
                      },
                    ),
                    leading: const Icon(Icons.volume_up_rounded),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

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

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final synthService = ref.read(breathSynthServiceProvider);
    await synthService.initialize();
    final config = synthService.currentConfig;
    return SettingsState(
      sfxEnabled: config.sfxEnabled,
      hapticsEnabled: config.hapticsEnabled,
      volume: config.baseVolume,
    );
  }

  Future<void> setSfxEnabled({required bool enabled}) async {
    final synthService = ref.read(breathSynthServiceProvider);
    final current = state.value ?? const SettingsState();
    final newState = current.copyWith(sfxEnabled: enabled);
    state = AsyncData(newState);

    await synthService.updateConfig(
      BreathSynthConfig(
        sfxEnabled: enabled,
        hapticsEnabled: newState.hapticsEnabled,
        baseVolume: newState.volume,
      ),
    );
  }

  Future<void> setHapticsEnabled({required bool enabled}) async {
    final synthService = ref.read(breathSynthServiceProvider);
    final current = state.value ?? const SettingsState();
    final newState = current.copyWith(hapticsEnabled: enabled);
    state = AsyncData(newState);

    await synthService.updateConfig(
      BreathSynthConfig(
        sfxEnabled: newState.sfxEnabled,
        hapticsEnabled: enabled,
        baseVolume: newState.volume,
      ),
    );
  }

  Future<void> setVolume(double volume) async {
    final synthService = ref.read(breathSynthServiceProvider);
    final current = state.value ?? const SettingsState();
    final newState = current.copyWith(volume: volume);
    state = AsyncData(newState);

    await synthService.updateConfig(
      BreathSynthConfig(
        sfxEnabled: newState.sfxEnabled,
        hapticsEnabled: newState.hapticsEnabled,
        baseVolume: volume,
      ),
    );
  }
}
