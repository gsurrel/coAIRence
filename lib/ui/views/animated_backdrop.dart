import 'package:coairence/ui/widgets/shader_backdrop.dart';
import 'package:flutter/material.dart';

class AnimatedBackdrop extends StatelessWidget {
  const AnimatedBackdrop({required Animation<double> animation, super.key})
    : _animation = animation;

  final Animation<double> _animation;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder:
        (BuildContext context, Widget? child) =>
            ShaderBackdrop(animationValue: _animation.value),
  );
}
