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
