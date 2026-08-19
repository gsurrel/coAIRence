import 'package:coairence/ui/widgets/shader_backdrop.dart';
import 'package:material_ui/material_ui.dart';

class AnimatedBackdrop extends StatelessWidget {
  const AnimatedBackdrop({required this._animation, super.key});

  final Animation<double> _animation;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder: (context, child) =>
        ShaderBackdrop(animationValue: _animation.value),
  );
}
