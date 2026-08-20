import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Phases of a breathing cycle.
enum BreathPhase { idle, inhale, holdIn, exhale, holdOut }

/// Configuration for synthesized breath feedback.
class BreathSynthConfig {
  const BreathSynthConfig({
    this.sfxEnabled = true,
    this.hapticsEnabled = true,
    this.baseVolume = 0.5,
  });

  final bool sfxEnabled;
  final bool hapticsEnabled;
  final double baseVolume;
}

/// Procedural breath SFX engine with page-level lifecycle.
///
/// Initializes SoLoud once, creates persistent oscillator sources, and
/// modulates them smoothly across multiple exercises without restarts.
/// Sources are created once and persist until the app/page is destroyed.
class BreathSynthService {
  BreathSynthService();

  final SoLoud _soloud = SoLoud.instance;

  // Persistent layered sources
  AudioSource? _droneSource;
  AudioSource? _melodySource;
  AudioSource? _shimmerSource;

  SoundHandle? _droneHandle;
  SoundHandle? _melodyHandle;
  SoundHandle? _shimmerHandle;

  BreathSynthConfig _config = const BreathSynthConfig();

  /// Exposes current config for reading by settings UI.
  BreathSynthConfig get currentConfig => _config;
  bool _isInitialized = false;
  bool _isActive = false; // Whether audio is currently playing for an exercise

  // Musical frequency ranges (Hz)
  static const double _droneMin = 55;
  static const double _droneMax = 82;
  static const double _melodyMin = 220;
  static const double _melodyMax = 330;
  static const double _shimmerBase = 880;

  /// Initializes SoLoud and creates persistent sources.
  /// Call once when the page loads, not per-exercise.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _soloud.init();
      await _loadSettings();
      await _createSources();
      _isInitialized = true;
      debugPrint('[BreathSynth] initialized successfully');
    } on Exception catch (e) {
      debugPrint('[BreathSynth] initialization failed: $e');
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _config = BreathSynthConfig(
      sfxEnabled: prefs.getBool('sfx_enabled') ?? true,
      hapticsEnabled: prefs.getBool('haptics_enabled') ?? true,
      baseVolume: prefs.getDouble('sfx_volume') ?? 0.5,
    );
  }

  Future<void> updateConfig(BreathSynthConfig config) async {
    _config = config;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_enabled', config.sfxEnabled);
    await prefs.setBool('haptics_enabled', config.hapticsEnabled);
    await prefs.setDouble('sfx_volume', config.baseVolume);

    if (_isActive) {
      final vol = config.sfxEnabled ? config.baseVolume : 0.0;
      _applyVolume(vol);
    }
  }

  /// Creates the three layered oscillator sources once.
  /// They persist across exercises and only get disposed when the service is destroyed.
  Future<void> _createSources() async {
    if (!_config.sfxEnabled) return;

    // Drone: low sine with superWave for thickness
    _droneSource = await _soloud.loadWaveform(WaveForm.sin, true, 1, 0);
    if (_droneSource != null) {
      _soloud.setWaveformSuperWave(_droneSource!, true);
      _soloud.setWaveformDetune(_droneSource!, 0.3);
      _soloud.setWaveformFreq(_droneSource!, _droneMin);
    }

    // Melody: triangle wave for warmth
    _melodySource = await _soloud.loadWaveform(WaveForm.triangle, true, 1, 0);
    if (_melodySource != null) {
      _soloud.setWaveformSuperWave(
        _melodySource!,
        true,
      );
      _soloud.setWaveformDetune(_melodySource!, 0.4);
      _soloud.setWaveformFreq(_melodySource!, _melodyMin);
    }

    // Shimmer: high sine for airy texture
    _shimmerSource = await _soloud.loadWaveform(WaveForm.sin, true, 1, 0);
    if (_shimmerSource != null) {
      _soloud.setWaveformFreq(_shimmerSource!, _shimmerBase);
    }

    debugPrint('[BreathSynth] sources created');
  }

  /// Starts audio playback for an exercise.
  /// Creates sound handles and fades in over 1 second.
  /// Safe to call multiple times — only starts if not already active.
  Future<void> start() async {
    if (!_isInitialized) {
      debugPrint('[BreathSynth] start() called before initialize()');
      await initialize();
    }
    if (_isActive) {
      debugPrint('[BreathSynth] start() skipped: already active');
      return;
    }
    if (!_config.sfxEnabled) {
      debugPrint('[BreathSynth] start() skipped: SFX disabled');
      return;
    }
    if (_droneSource == null) {
      debugPrint('[BreathSynth] sources not created, creating now...');
      await _createSources();
    }

    // Play all sources at zero volume
    if (_droneSource != null) {
      _droneHandle = _soloud.play(_droneSource!, volume: 0);
    }
    if (_melodySource != null) {
      _melodyHandle = _soloud.play(_melodySource!, volume: 0);
    }
    if (_shimmerSource != null) {
      _shimmerHandle = _soloud.play(_shimmerSource!, volume: 0);
    }

    _isActive = true;
    debugPrint('[BreathSynth] starting with fade-in...');

    // Fade in over 1 second
    _soloud.fadeVolume(
      _droneHandle!,
      _config.baseVolume * 0.4,
      const Duration(milliseconds: 1000),
    );
    _soloud.fadeVolume(
      _melodyHandle!,
      _config.baseVolume * 0.6,
      const Duration(milliseconds: 1000),
    );
    _soloud.fadeVolume(
      _shimmerHandle!,
      _config.baseVolume * 0.15,
      const Duration(milliseconds: 1200),
    );
  }

  void _applyVolume(double baseVol) {
    if (_droneHandle != null) _soloud.setVolume(_droneHandle!, baseVol * 0.4);
    if (_melodyHandle != null) _soloud.setVolume(_melodyHandle!, baseVol * 0.6);
    if (_shimmerHandle != null) {
      _soloud.setVolume(_shimmerHandle!, baseVol * 0.15);
    }
  }

  /// Called every animation frame to modulate the sound.
  void update(double breathPercentage, BreathPhase phase) {
    if (!_isActive || !_config.sfxEnabled) return;

    final curvedPct = switch (phase) {
      BreathPhase.inhale => _easeInOutCubic(breathPercentage),
      BreathPhase.exhale => 1 - _easeInOutCubic(1 - breathPercentage),
      _ => breathPercentage,
    };

    // Drone
    if (_droneSource != null) {
      final droneFreq = _droneMin + (_droneMax - _droneMin) * curvedPct * 0.5;
      _soloud.setWaveformFreq(_droneSource!, droneFreq);
    }

    // Melody
    if (_melodySource != null) {
      final melodyFreq = _melodyMin + (_melodyMax - _melodyMin) * curvedPct;
      _soloud.setWaveformFreq(_melodySource!, melodyFreq);
    }

    // Shimmer
    if (_shimmerSource != null) {
      final shimmerFreq = _shimmerBase + (220 * curvedPct);
      _soloud.setWaveformFreq(_shimmerSource!, shimmerFreq);
    }

    // Dynamic volume per phase
    final volumeMultiplier = switch (phase) {
      BreathPhase.inhale => 0.8 + (0.2 * breathPercentage),
      BreathPhase.exhale => 1.0 - (0.3 * (1 - breathPercentage)),
      BreathPhase.holdIn => 0.85,
      BreathPhase.holdOut => 0.5,
      BreathPhase.idle => 0.7,
    };

    _applyVolume(_config.baseVolume * volumeMultiplier);
  }

  double _easeInOutCubic(double t) {
    return t < 0.5
        ? 4 * t * t * t
        : 1 - (-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2) / 2;
  }

  Future<void> triggerHaptic(BreathPhase phase) async {
    if (!_config.hapticsEnabled) return;

    final canVibrate = await Haptics.canVibrate();
    if (!canVibrate) return;

    final type = switch (phase) {
      BreathPhase.inhale => HapticsType.light,
      BreathPhase.exhale => HapticsType.soft,
      BreathPhase.holdIn => HapticsType.heavy,
      BreathPhase.holdOut => HapticsType.selection,
      BreathPhase.idle => null,
    };

    if (type != null) {
      await Haptics.vibrate(type);
    }
  }

  /// Stops audio for the current exercise with a gentle fade-out.
  /// Does NOT dispose sources — they persist for the next exercise.
  /// Safe to call multiple times.
  Future<void> stop() async {
    if (!_isActive) {
      debugPrint('[BreathSynth] stop() skipped: not active');
      return;
    }

    debugPrint('[BreathSynth] fading out...');

    // Fade out over 1.2 seconds
    const fadeDuration = Duration(milliseconds: 1200);
    if (_droneHandle != null) {
      _soloud.fadeVolume(_droneHandle!, 0, fadeDuration);
    }
    if (_melodyHandle != null) {
      _soloud.fadeVolume(_melodyHandle!, 0, fadeDuration);
    }
    if (_shimmerHandle != null) {
      _soloud.fadeVolume(_shimmerHandle!, 0, fadeDuration);
    }

    // Wait for fade to complete
    await Future<void>.delayed(const Duration(milliseconds: 1300));

    // Stop the handles but keep the sources alive
    if (_droneHandle != null) {
      unawaited(_soloud.stop(_droneHandle!));
      _droneHandle = null;
    }
    if (_melodyHandle != null) {
      unawaited(_soloud.stop(_melodyHandle!));
      _melodyHandle = null;
    }
    if (_shimmerHandle != null) {
      unawaited(_soloud.stop(_shimmerHandle!));
      _shimmerHandle = null;
    }

    _isActive = false;
    debugPrint('[BreathSynth] stopped, sources preserved');
  }

  /// Full cleanup — only call when truly destroying the service/page.
  /// Disposes all sources and deinits SoLoud.
  Future<void> dispose() async {
    debugPrint('[BreathSynth] full dispose called');
    await stop();

    // Now dispose the persistent sources
    if (_droneSource != null) {
      await _soloud.disposeSource(_droneSource!);
      _droneSource = null;
    }
    if (_melodySource != null) {
      await _soloud.disposeSource(_melodySource!);
      _melodySource = null;
    }
    if (_shimmerSource != null) {
      await _soloud.disposeSource(_shimmerSource!);
      _shimmerSource = null;
    }

    _soloud.deinit();
    _isInitialized = false;
    debugPrint('[BreathSynth] fully disposed');
  }
}

final breathSynthServiceProvider = Provider<BreathSynthService>((ref) {
  final service = BreathSynthService();
  ref.onDispose(service.dispose);
  return service;
});
