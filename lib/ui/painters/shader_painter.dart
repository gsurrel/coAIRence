import 'dart:ui' as ui;

import 'package:coairence/ui/widgets/shader_backdrop.dart';
import 'package:material_ui/material_ui.dart';

/// Draws a cached, pre-rendered snapshot of the shader instead of
/// re-executing the fragment shader. `image` is produced by
/// [ShaderBackdrop]'s snapshot capture (taken once, right after a page
/// transition settles) and reused for every frame while the backdrop is
/// idle — so this painter's per-frame cost is a single image blit, not a
/// 45-iteration-per-pixel shader.
class ShaderPainter extends CustomPainter {
  ShaderPainter({required this.image, required this.fullSize});

  final ui.Image image;
  final Size fullSize;

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, fullSize.width, fullSize.height),
      image: image,
      fit: BoxFit.fill,
    );
  }

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.fullSize != fullSize;
}
