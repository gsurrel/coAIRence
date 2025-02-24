import 'dart:ui';
import 'package:flutter/material.dart';

class ShaderPainter extends CustomPainter {
  ShaderPainter({
    required this.shader,
    required this.fullSize,
    required this.animationValue,
  }) : _paint =
           Paint()
             ..shader =
                 (shader
                   ..setFloat(_uWidth, fullSize.width)
                   ..setFloat(_uHeight, fullSize.height)
                   ..setFloat(_uAngle, 90 + animationValue / 2));

  static const int _uWidth = 0;
  static const int _uHeight = 1;
  static const int _uAngle = 2;

  final FragmentShader shader;
  final Size fullSize;
  final double animationValue;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawRect(
    Rect.fromLTWH(0, 0, fullSize.width, fullSize.height),
    _paint,
  );

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
