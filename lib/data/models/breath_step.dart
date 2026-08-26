/// How air should be moved during a breath step.
enum BreathMode {
  /// Both nostrils, normal breathing. The default.
  nose,

  /// Left nostril only, right nostril blocked.
  noseLeft,

  /// Right nostril only, left nostril blocked.
  noseRight,

  /// Mouth breathing.
  mouth,
}

class BreathStep({
  required final double breathTo,
  required final Duration duration,
  final BreathMode mode = BreathMode.nose,
});

/// The direction of movement within a breath cycle at a given moment.
///
/// Lives alongside [BreathMode] since both describe "what's happening right
/// now" in a cycle, purely from the pattern's shape — used by anything that
/// needs to react to phase changes (audio, haptics), not just the widget
/// that first needed it.
enum BreathPhase {
  idle,
  inhale,
  holdIn,
  exhale,
  holdOut,
}
