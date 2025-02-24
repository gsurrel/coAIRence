import 'dart:ui';
import 'package:coairence/ui/painters/shader_painter.dart';
import 'package:flutter/material.dart';

class ShaderBackdrop extends StatefulWidget {
  const ShaderBackdrop({required this.animationValue, super.key});

  final double animationValue;

  @override
  State<ShaderBackdrop> createState() => _ShaderBackdropState();
}

class _ShaderBackdropState extends State<ShaderBackdrop> {
  FragmentShader? shader;

  @override
  void initState() {
    super.initState();
    _loadMyShader();
  }

  Future<void> _loadMyShader() async {
    const path = 'lib/particle_shader.frag';
    final program = await FragmentProgram.fromAsset(path);
    setState(() => shader = program.fragmentShader());
  }

  @override
  void dispose() => super.dispose();

  @override
  Widget build(BuildContext context) => switch (shader) {
    null => const SizedBox.expand(),
    final shader => LayoutBuilder(
      builder:
          (context, constraints) => CustomPaint(
            painter: ShaderPainter(
              shader: shader,
              fullSize: Size(constraints.maxWidth, constraints.maxHeight),
              animationValue: widget.animationValue,
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
    ),
  };
}
