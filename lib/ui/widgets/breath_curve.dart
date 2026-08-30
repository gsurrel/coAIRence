import 'dart:math';
import 'dart:ui' as ui;

import 'package:coairence/data/models/breath_step.dart';
import 'package:material_ui/material_ui.dart';

class BreathCurve extends StatefulWidget {
  const BreathCurve({
    required this.cycleProgress,
    required this.breathPercent,
    this.mode = BreathMode.nose,
    super.key,
  });

  final double cycleProgress;
  final double breathPercent;

  /// How air is being moved right now — changes how the shape is filled
  /// (see [_BreathPainter]).
  final BreathMode mode;

  /// How long a mode change (e.g. switching nostrils, or into/out of
  /// mouth breathing) takes to ease in visually.
  static const Duration modeTransitionDuration = Duration(milliseconds: 350);

  @override
  State<BreathCurve> createState() => _BreathCurveState();
}

class _BreathCurveState extends State<BreathCurve>
    with SingleTickerProviderStateMixin {
  late final AnimationController _modeController;
  late BreathMode _previousMode;

  _BreathPainter? _painter;

  @override
  void initState() {
    super.initState();
    _previousMode = widget.mode;
    _modeController = AnimationController(
      vsync: this,
      duration: BreathCurve.modeTransitionDuration,
      value: 1,
    );
  }

  @override
  void didUpdateWidget(BreathCurve oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _previousMode = oldWidget.mode;
      _modeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _modeController.dispose();
    _painter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final painter = _painter ??= _BreathPainter(color: color)
      ..updateColor(color);

    return AnimatedBuilder(
      animation: _modeController,
      builder: (context, _) {
        painter.update(
          cycleProgress: widget.cycleProgress,
          breathPercent: widget.breathPercent,
          mode: widget.mode,
          previousMode: _previousMode,
          modeT: Curves.easeInOut.transform(_modeController.value),
        );
        return CustomPaint(size: Size.infinite, painter: painter);
      },
    );
  }
}

/// The visual weights that describe how a [BreathMode] fills the shape,
/// so two modes can be smoothly cross-faded during a transition.
class _FillDescriptor {
  const _FillDescriptor(this.leftAlpha, this.rightAlpha);

  factory _FillDescriptor.lerp(_FillDescriptor a, _FillDescriptor b, double t) {
    return _FillDescriptor(
      ui.lerpDouble(a.leftAlpha, b.leftAlpha, t)!,
      ui.lerpDouble(a.rightAlpha, b.rightAlpha, t)!,
    );
  }

  factory _FillDescriptor.forMode(BreathMode mode) => switch (mode) {
    BreathMode.nose => const _FillDescriptor(_litAlpha, _litAlpha),
    BreathMode.noseLeft => const _FillDescriptor(_litAlpha, _dimAlpha),
    BreathMode.noseRight => const _FillDescriptor(_dimAlpha, _litAlpha),
    // No air passes through the nose during mouth breathing, so the
    // shape's fill empties out entirely.
    BreathMode.mouth => const _FillDescriptor(0, 0),
  };

  /// Alpha used for a normally-lit (breathing) side of the shape.
  static const double _litAlpha = 150;

  /// Alpha used for a nostril that's currently blocked, or the fill when
  /// air isn't passing through the nose at all.
  static const double _dimAlpha = 40;

  final double leftAlpha;
  final double rightAlpha;
}

class _BreathPainter extends CustomPainter with ChangeNotifier {
  _BreathPainter({required Color color})
    : _color = color,
      _paintBorder = Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
      _paintFill = Paint();

  double breathPercent = 0;
  double cycleProgress = 0;
  BreathMode mode = BreathMode.nose;

  /// The mode being eased away from, so a mode change can be
  /// cross-faded rather than switching instantly.
  BreathMode previousMode = BreathMode.nose;

  /// Progress (0.0-1.0, eased) from [previousMode] to [mode].
  double modeT = 1;

  Color _color;
  final Paint _paintBorder;
  final Paint _paintFill;

  void updateColor(Color color) {
    if (_color == color) return;
    _color = color;
    _paintBorder.color = color;
  }

  void update({
    required double cycleProgress,
    required double breathPercent,
    required BreathMode mode,
    required BreathMode previousMode,
    required double modeT,
  }) {
    this.cycleProgress = cycleProgress;
    this.breathPercent = breathPercent;
    this.mode = mode;
    this.previousMode = previousMode;
    this.modeT = modeT;
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final offset = centerX * breathPercent;
    final height = cycleProgress * size.height;
    final lipSize = 2 * sqrt(offset);

    // Draw the path on the canvas
    final path = Path()
      // Move to the starting point of the left bracket
      ..moveTo(centerX - offset, height)
      // Draw the top lip
      ..quadraticBezierTo(
        centerX,
        height - lipSize,
        centerX + offset,
        height,
      )
      // Draw the bottom lip
      ..quadraticBezierTo(
        centerX,
        height + lipSize,
        centerX - offset,
        height,
      )
      ..close();

    final fill = _FillDescriptor.lerp(
      _FillDescriptor.forMode(previousMode),
      _FillDescriptor.forMode(mode),
      modeT,
    );

    _updateFillPaint(centerX: centerX, offset: offset, fill: fill);
    canvas
      ..drawPath(path, _paintFill)
      ..drawPath(path, _paintBorder);
  }

  /// A horizontal gradient with a sharp split at the shape's midline: the
  /// open nostril stays fully lit, the blocked one dims sharply rather
  /// than fading gradually. Also covers the plain (equal-alpha) and empty
  /// (both sides near zero, mouth breathing) cases as degenerate gradients.
  ///
  /// Per the app's mirrored convention, screen-right dims for
  /// [BreathMode.noseLeft] (left nostril open) and screen-left dims for
  /// [BreathMode.noseRight].
  void _updateFillPaint({
    required double centerX,
    required double offset,
    required _FillDescriptor fill,
  }) {
    final leftAlpha = fill.leftAlpha.round();
    final rightAlpha = fill.rightAlpha.round();

    // Guard against a zero-width gradient vector (offset == 0, e.g. right
    // at the start/end of a step) — fall back to a flat, evenly-blended
    // fill rather than handing Skia a degenerate linear gradient.
    if (offset == 0) {
      _paintFill
        ..shader = null
        ..color = _color.withAlpha((leftAlpha + rightAlpha) ~/ 2);
      return;
    }

    _paintFill.shader = ui.Gradient.linear(
      Offset(centerX - offset, 0),
      Offset(centerX + offset, 0),
      [
        _color.withAlpha(leftAlpha),
        _color.withAlpha(leftAlpha),
        _color.withAlpha(rightAlpha),
        _color.withAlpha(rightAlpha),
      ],
      const [0.0, 0.49, 0.51, 1.0],
    );
  }

  @override
  bool shouldRepaint(_BreathPainter oldDelegate) => false;
}
