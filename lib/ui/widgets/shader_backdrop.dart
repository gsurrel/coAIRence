import 'dart:async';
import 'dart:ui' as ui;

import 'package:coairence/ui/painters/shader_painter.dart';
import 'package:coairence/ui/views/animated_backdrop.dart';
import 'package:material_ui/material_ui.dart';

/// Paints the particle shader live while a page transition is in progress,
/// and freezes on a cached snapshot of the last frame once the transition
/// stops — so the shader only burns GPU cycles while the backdrop is
/// actually supposed to be animating, not while sitting idle on a page.
///
/// The shader itself (see particle_shader.frag) is a 45-iteration,
/// transcendental-heavy Shadertoy-style effect — cheap on a desktop GPU,
/// but expensive enough on older mobile GPUs (tested: Galaxy S8, legacy
/// Skia GL backend) that re-running it continuously was costing ~50ms of
/// raster time on every frame, including frames where the app was just
/// sitting still. Since the shader is only meant to move during a
/// transition (~300ms), that's the only time it needs to be live; the
/// rest of the time a static cached bitmap is visually indistinguishable
/// from — and vastly cheaper than — the shader still running.
///
/// (An earlier version of this also adapted the shader's render
/// resolution to measured raster cost. That was dropped: it added a lot
/// of state-machine complexity for a one-shot capture that isn't the
/// actual per-frame cost problem, and it introduced its own bugs around
/// live/frozen resolution mismatches. This version always renders at
/// native resolution.)
class ShaderBackdrop extends StatefulWidget {
  const ShaderBackdrop({
    required this.animationValue,
    required this.isAnimating,
    super.key,
  });

  /// Current progress/value of the page transition animation.
  final double animationValue;

  /// True for every frame the page-transition animation is actively
  /// running (forward or reverse); false once it has stopped.
  final bool isAnimating;

  @override
  State<ShaderBackdrop> createState() => _ShaderBackdropState();
}

class _ShaderBackdropState extends State<ShaderBackdrop> {
  ui.FragmentShader? _shader;

  /// Cached bitmap shown while `.isAnimating` is false.
  ui.Image? _frozenImage;

  /// Layout size for which [_frozenImage] was captured.
  Size? _frozenForSize;

  /// Guards against a stale async capture applying itself after being
  /// superseded (a new transition started, or the widget was disposed).
  int _captureRequestId = 0;

  /// True while an async snapshot capture is in flight.
  bool _isCapturing = false;

  Size? _lastLayoutSize;

  @override
  void initState() {
    super.initState();
    unawaited(_loadShader());
  }

  Future<void> _loadShader() async {
    const path = 'lib/particle_shader.frag';
    final program = await ui.FragmentProgram.fromAsset(path);
    if (!mounted) return;
    setState(() => _shader = program.fragmentShader());
  }

  @override
  void didUpdateWidget(ShaderBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isAnimating && !widget.isAnimating) {
      // Transition stopped: capture final frame.
      _startCapture();
    } else if (!oldWidget.isAnimating && widget.isAnimating) {
      // A new transition just started: any capture still in flight from
      // the previous idle period is now stale — its result must not be
      // applied when it resolves.
      _captureRequestId++;
      _isCapturing = false;
    }
  }

  @override
  void dispose() {
    _frozenImage?.dispose();
    super.dispose();
  }

  void _startCapture() {
    if (_isCapturing) return;
    _isCapturing = true;
    unawaited(_captureSnapshot());
  }

  Future<void> _captureSnapshot() async {
    final shader = _shader;
    final fullSize = _lastLayoutSize;

    if (shader == null || fullSize == null || fullSize.isEmpty) {
      if (mounted) setState(() => _isCapturing = false);
      return;
    }

    final requestId = ++_captureRequestId;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    _paintShader(canvas, shader, fullSize);
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      fullSize.width.ceil(),
      fullSize.height.ceil(),
    );
    picture.dispose();

    if (!mounted || requestId != _captureRequestId) {
      // Superseded by a new transition starting, or the widget went
      // away, while this capture was in flight — discard it. Note we do
      // NOT check widget.isAnimating here: if a new transition started,
      // _captureRequestId was already bumped above, so that case is
      // already covered by the requestId check.
      image.dispose();
      return;
    }

    final previousImage = _frozenImage;
    setState(() {
      _frozenImage = image;
      _frozenForSize = fullSize;
      _isCapturing = false;
    });
    previousImage?.dispose();
  }

  void _paintShader(ui.Canvas canvas, ui.FragmentShader shader, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      // uTime uniform: mapped from animationValue as per original tuning.
      ..setFloat(2, 90 + widget.animationValue / 2);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shader = _shader;
    if (shader == null) return const SizedBox.expand();

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullSize = Size(constraints.maxWidth, constraints.maxHeight);
        _lastLayoutSize = fullSize;

        final frozen = _frozenImage;
        final needsCapture = frozen == null || _frozenForSize != fullSize;

        // Covers first-ever build and resize/rotation while idle: kick
        // off a capture, and (via _isCapturing below) render live until
        // it resolves rather than showing nothing or a stale bitmap.
        if (needsCapture && !widget.isAnimating) {
          _startCapture();
        }

        // LIVE PATH: the transition is actively running, OR a capture is
        // in flight (see _isCapturing's doc) — this covers every normal
        // transition-end, not just resizes: right after a transition
        // stops, `frozen` is still the *previous* transition's image and
        // `needsCapture` is false (size hasn't changed), so this must
        // check _isCapturing alone, not gate it on needsCapture too.
        if (widget.isAnimating || _isCapturing) {
          return CustomPaint(
            painter: _LiveShaderPainter(
              shader: shader,
              fullSize: fullSize,
              animationValue: widget.animationValue,
            ),
            size: fullSize,
          );
        }

        // IDLE PATH: blit the cached snapshot. No shader execution here.
        return CustomPaint(
          painter: ShaderPainter(image: frozen!, fullSize: fullSize),
          size: fullSize,
        );
      },
    );
  }
}

/// Paints the shader live, every frame, at native resolution — used only
/// while a page transition is actively animating, or while bridging the
/// async gap right after one ends (see ShaderBackdrop._isCapturing).
class _LiveShaderPainter extends CustomPainter {
  _LiveShaderPainter({
    required this.shader,
    required this.fullSize,
    required this.animationValue,
  });

  final ui.FragmentShader shader;
  final Size fullSize;
  final double animationValue;
  final Paint _paint = Paint();

  @override
  void paint(ui.Canvas canvas, Size size) {
    shader
      ..setFloat(0, fullSize.width)
      ..setFloat(1, fullSize.height)
      ..setFloat(2, 90 + animationValue / 2);

    _paint.shader = shader;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, fullSize.width, fullSize.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LiveShaderPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.shader != shader ||
      oldDelegate.fullSize != fullSize;
}
