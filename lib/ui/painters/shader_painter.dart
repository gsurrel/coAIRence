import 'dart:ui';
import 'package:flutter/material.dart';

class ShaderPainter extends CustomPainter {
  ShaderPainter({
    required this.shader,
    required this.fullSize,
    required this.animationValue,
  });

  static const int _uWidth = 0;
  static const int _uHeight = 1;
  static const int _uAngle = 2;

  final FragmentShader shader;
  final Size fullSize;
  final double animationValue;
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(_uWidth, fullSize.width)
      ..setFloat(_uHeight, fullSize.height)
      ..setFloat(_uAngle, 90 + animationValue / 2);

    _paint.shader = shader;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, fullSize.width, fullSize.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.shader != shader;
  }
}
