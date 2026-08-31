import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:coairence/data/models/breath_step.dart';
import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/services/pink_noise_generator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
/// Initializes SoLoud once, creates persistent sources, and modulates them
/// smoothly across multiple exercises without restarts. Sources are
/// created once and persist until the app/page is destroyed.
///
/// Sound design: a looped pink-noise "wind" sample is the primary,
/// ever-present texture — its fullness breathes with inhalation instead of
/// sweeping a discrete pitch, which reads as far more organic than a pure
/// oscillator tone. A very quiet sine "drone" sits underneath as a
/// grounding hum. A "melody" tone only fades in while a special breath
/// mode (nostril-only / mouth) is active, giving those steps a distinct,
/// composed cue rather than a constant hum. A "shimmer" tone is silent
/// except for a brief chime on every mode change.
///
/// All of this is driven by its own wall-clock timer (see [startCycle]),
/// not by the UI's per-frame animation ticks — Flutter's animation
/// tickers stop firing when the app isn't in the foreground, which used
/// to freeze the sound mid-tone whenever the app was backgrounded. A
/// plain [Timer.periodic] keeps running independently of the renderer,
/// and because each tick recomputes cycle progress from real elapsed
/// time (not a tick counter), a throttled or delayed tick just catches
/// back up instead of drifting.
class BreathSynthService {
  BreathSynthService();

  final SoLoud _soloud = SoLoud.instance;

  // Persistent layered sources
  AudioSource? _windSource;
  AudioSource? _droneSource;
  AudioSource? _melodySource;
  AudioSource? _shimmerSource;

  SoundHandle? _windHandle;
  SoundHandle? _droneHandle;
  SoundHandle? _melodyHandle;
  SoundHandle? _shimmerHandle;

  BreathSynthConfig _config = const BreathSynthConfig();

  /// Exposes current config for reading by settings UI.
  BreathSynthConfig get currentConfig => _config;
  bool _isInitialized = false;
  bool _isActive = false; // Whether audio is currently playing for an exercise

  // --- Harmonic pitch model (drone/melody/shimmer only — the wind layer
  // isn't pitched) ---
  // The three tonal layers form a simple harmonic stack (root, octave,
  // octave+fifth) so they always stay consonant with one another
  // regardless of where the root currently sits.
  static const double _droneBaseHz = 110; // A2
  static const double _octaveRange = 1; // sweeps a full octave to full inhale
  static const double _smoothing = 0.18; // per-tick lerp factor
  static const Duration _tickInterval = Duration(milliseconds: 40); // ~25Hz

  double _currentRootFreq = _droneBaseHz;
  double _currentWindSpeed = 1;
  double _currentMelodyVol = 0;

  // --- Active-cycle clock state ---
  Timer? _clockTimer;
  BreathingPattern? _activePattern;
  Duration _activeCycleDuration = Duration.zero;
  Duration _activeTotalDuration = Duration.zero;
  double _activeSpeedMultiplier = 1;
  DateTime? _cycleStartedAt;

  BreathPhase _lastPhase = BreathPhase.idle;
  BreathMode _lastMode = BreathMode.nose;

  // Short audible "flag" on a mode change (e.g. switching nostrils),
  // decayed back to 0 over the following few ticks — see [_onClockTick].
  double _transitionPulse = 0;

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

  /// Creates the persistent sources once. They persist across exercises
  /// and only get disposed when the service is destroyed.
  Future<void> _createSources() async {
    if (!_config.sfxEnabled) return;

    // Wind: looped pink-noise sample, the primary texture. Generated on
    // the fly in a background isolate (see pink_noise_generator.dart) so
    // no audio asset needs to ship with the app.
    // NOTE for Ploppe: `loadMem` + the `looping` param on `play()` are my
    // best understanding of the flutter_soloud 4.1.7 surface, but I
    // couldn't verify the exact signatures in this environment (no
    // pub.dev/docs access) — worth a quick check on-device.
    try {
      final windWavBytes = await Isolate.run(generatePinkNoiseWav);
      _windSource = await _soloud.loadMem('wind_noise.wav', windWavBytes);
    } on Exception catch (e) {
      debugPrint('[BreathSynth] failed to generate/load wind noise: $e');
    }

    // Drone: quiet low sine, a grounding hum underneath the wind.
    _droneSource = await _soloud.loadWaveform(WaveForm.sin, true, 1, 0);
    if (_droneSource != null) {
      _soloud.setWaveformSuperWave(_droneSource!, true);
      _soloud.setWaveformDetune(_droneSource!, 0.3);
      _soloud.setWaveformFreq(_droneSource!, _droneBaseHz);
    }

    // Melody: triangle wave, only heard during special breath modes.
    _melodySource = await _soloud.loadWaveform(WaveForm.triangle, true, 1, 0);
    if (_melodySource != null) {
      _soloud.setWaveformSuperWave(_melodySource!, true);
      _soloud.setWaveformDetune(_melodySource!, 0.4);
      _soloud.setWaveformFreq(_melodySource!, _droneBaseHz * 2);
    }

    // Shimmer: high sine, only heard as a brief chime on mode changes.
    _shimmerSource = await _soloud.loadWaveform(WaveForm.sin, true, 1, 0);
    if (_shimmerSource != null) {
      _soloud.setWaveformFreq(_shimmerSource!, _droneBaseHz * 3);
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

    // Play all sources at zero volume; melody/shimmer stay silent until
    // an event (special mode / transition) calls for them.
    if (_windSource != null) {
      _windHandle = _soloud.play(_windSource!, volume: 0, looping: true);
    }
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

    // Fade in over 1 second, at rest-state (idle-phase) levels.
    if (_windHandle != null) {
      _soloud.fadeVolume(
        _windHandle!,
        _config.baseVolume * 0.6,
        const Duration(milliseconds: 1000),
      );
    }
    if (_droneHandle != null) {
      _soloud.fadeVolume(
        _droneHandle!,
        _config.baseVolume * 0.08,
        const Duration(milliseconds: 1000),
      );
    }
  }

  /// Begins driving the audio (and haptics) for one full exercise —
  /// [totalRepetitions] cycles of [pattern], sped up by [speedMultiplier].
  ///
  /// Runs on its own [Timer.periodic], independent of the widget tree, so
  /// it keeps going smoothly even if the app is backgrounded and Flutter's
  /// animation frames stop. Call [stop] to end it early (e.g. the user
  /// leaves the page); it also stops itself once [totalRepetitions] have
  /// elapsed in real time.
  Future<void> startCycle({
    required BreathingPattern pattern,
    required int totalRepetitions,
    double speedMultiplier = 1,
  }) async {
    await start();

    final safeSpeed = speedMultiplier > 0 ? speedMultiplier : 1.0;

    _activePattern = pattern;
    _activeCycleDuration = pattern.totalDuration;
    _activeTotalDuration = Duration(
      microseconds:
          (pattern.totalDuration.inMicroseconds * totalRepetitions / safeSpeed)
              .round(),
    );
    _activeSpeedMultiplier = safeSpeed;
    _cycleStartedAt = DateTime.now();
    _lastPhase = BreathPhase.idle;
    _lastMode = BreathMode.nose;
    _transitionPulse = 0;
    _currentRootFreq = _droneBaseHz;
    _currentWindSpeed = 1;
    _currentMelodyVol = 0;

    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(_tickInterval, _onClockTick);
  }

  void _onClockTick(Timer timer) {
    final pattern = _activePattern;
    final startedAt = _cycleStartedAt;
    if (pattern == null || startedAt == null) {
      timer.cancel();
      return;
    }

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed >= _activeTotalDuration) {
      timer.cancel();
      if (_isActive) unawaited(stop());
      return;
    }

    final cycleMs = _activeCycleDuration.inMilliseconds;
    if (cycleMs == 0) return;

    final scaledElapsedMs = elapsed.inMilliseconds * _activeSpeedMultiplier;
    final progress = (scaledElapsedMs % cycleMs) / cycleMs;

    final breathPct = pattern.getBreathPercentage(progress);
    final phase = pattern.getBreathPhase(progress);
    final mode = pattern.getBreathMode(progress);

    _transitionPulse -= 0.05;
    if (_transitionPulse < 0) _transitionPulse = 0;

    if (mode != _lastMode) {
      // Audible + tactile "flag" the instant the guidance switches nostril
      // (or to/from mouth breathing), so it's followable without looking.
      _transitionPulse = 1;
      unawaited(_triggerModeChangeHaptic());
    }

    if (_isActive && _config.sfxEnabled) {
      _applyModulation(breathPct, phase, mode);
    }

    if (phase != _lastPhase && phase != BreathPhase.idle) {
      unawaited(triggerHaptic(phase));
    }

    _lastPhase = phase;
    _lastMode = mode;
  }

  /// Applies volume/pitch/pan for the current tick across all layers.
  void _applyModulation(double breathPct, BreathPhase phase, BreathMode mode) {
    final phaseMultiplier = switch (phase) {
      BreathPhase.inhale => 0.75 + (0.35 * breathPct),
      BreathPhase.exhale => 1.0 - (0.35 * (1 - breathPct)),
      BreathPhase.holdIn => 0.9,
      BreathPhase.holdOut => 0.55,
      BreathPhase.idle => 0.7,
    };
    final baseVol = _config.baseVolume * phaseMultiplier;

    // Wind: primary texture. Fullness breathes with inhalation; no
    // discrete pitch, so nothing here reads as a "synth tone."
    if (_windHandle != null) {
      _soloud.setVolume(_windHandle!, baseVol * 0.85);
      final targetSpeed = 0.92 + 0.16 * breathPct;
      _currentWindSpeed += (targetSpeed - _currentWindSpeed) * _smoothing;
      _soloud.setRelativePlaySpeed(_windHandle!, _currentWindSpeed);
    }

    // Drone: very quiet grounding hum, still pitch-linked to inhalation
    // depth for a subtle sense of "rising" underneath the wind.
    final targetRoot = _droneBaseHz * pow(2, breathPct * _octaveRange);
    _currentRootFreq += (targetRoot - _currentRootFreq) * _smoothing;
    if (_droneSource != null) {
      _soloud.setWaveformFreq(_droneSource!, _currentRootFreq);
    }
    if (_droneHandle != null) {
      _soloud.setVolume(_droneHandle!, baseVol * 0.1);
    }

    // Melody: the "composed tone" cue — only present while a special
    // breath mode (nostril-only / mouth) is active, silent during plain
    // nose breathing so it never becomes a constant background hum.
    final isSpecialMode = mode != BreathMode.nose;
    final melodyTarget = isSpecialMode ? baseVol * 0.4 : 0.0;
    _currentMelodyVol += (melodyTarget - _currentMelodyVol) * _smoothing;
    if (_melodySource != null) {
      _soloud.setWaveformFreq(_melodySource!, _currentRootFreq * 2);
    }
    if (_melodyHandle != null) {
      _soloud.setVolume(_melodyHandle!, _currentMelodyVol);
    }

    // Shimmer: silent except for the brief chime on a mode change.
    if (_shimmerSource != null) {
      _soloud.setWaveformFreq(_shimmerSource!, _currentRootFreq * 3);
    }
    if (_shimmerHandle != null) {
      _soloud.setVolume(_shimmerHandle!, baseVol * 0.5 * _transitionPulse);
    }

    // Spatial: wind + melody pan to the open nostril, so the exercise is
    // followable by ear alone; the drone stays centered as a steady
    // anchor.
    final pan = switch (mode) {
      BreathMode.noseLeft => -0.85,
      BreathMode.noseRight => 0.85,
      BreathMode.nose || BreathMode.mouth => 0.0,
    };
    if (_windHandle != null) _soloud.setPan(_windHandle!, pan);
    if (_melodyHandle != null) _soloud.setPan(_melodyHandle!, pan);
    if (_shimmerHandle != null) _soloud.setPan(_shimmerHandle!, pan);
  }

  void _applyVolume(double baseVol) {
    // Live rescale for the always-on layers when the user adjusts the
    // volume slider mid-exercise. Melody/shimmer are event-driven and get
    // corrected on the next tick by [_applyModulation].
    if (_windHandle != null) _soloud.setVolume(_windHandle!, baseVol * 0.85);
    if (_droneHandle != null) _soloud.setVolume(_droneHandle!, baseVol * 0.1);
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

  Future<void> _triggerModeChangeHaptic() async {
    if (!_config.hapticsEnabled) return;

    final canVibrate = await Haptics.canVibrate();
    if (!canVibrate) return;

    await Haptics.vibrate(HapticsType.selection);
  }

  /// Stops audio for the current exercise with a gentle fade-out, and
  /// cancels the driving clock started by [startCycle].
  /// Does NOT dispose sources — they persist for the next exercise.
  /// Safe to call multiple times.
  Future<void> stop() async {
    _clockTimer?.cancel();
    _clockTimer = null;
    _cycleStartedAt = null;
    _activePattern = null;

    if (!_isActive) {
      debugPrint('[BreathSynth] stop() skipped: not active');
      return;
    }

    debugPrint('[BreathSynth] fading out...');

    // Fade out over 1.2 seconds
    const fadeDuration = Duration(milliseconds: 1200);
    if (_windHandle != null) {
      _soloud.fadeVolume(_windHandle!, 0, fadeDuration);
    }
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
    if (_windHandle != null) {
      unawaited(_soloud.stop(_windHandle!));
      _windHandle = null;
    }
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
    if (_windSource != null) {
      await _soloud.disposeSource(_windSource!);
      _windSource = null;
    }
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
