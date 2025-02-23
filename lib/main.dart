import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(const CoAIRenceApp());

class CoAIRenceApp extends StatelessWidget {
  const CoAIRenceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'coAIRence',
    theme: ThemeData(
      colorSchemeSeed: Colors.purple,
      brightness: Brightness.dark,
    ),
    home: const MainScaffold(),
  );
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 2;
  int _previousIndex = 2;

  Widget _getPageForIndex(int index) => switch (index) {
    0 => const Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    1 => const Center(
      child: Text('Exercises Page', style: TextStyle(fontSize: 24)),
    ),
    2 => const StartPage(),
    3 => const Center(
      child: Text('Profile Page', style: TextStyle(fontSize: 24)),
    ),
    4 => const Center(
      child: Text('Settings Page', style: TextStyle(fontSize: 24)),
    ),
    _ => const StartPage(),
  };

  void _onItemTapped(int targetIndex) {
    if (targetIndex == _currentIndex) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = targetIndex;
    });
  }

  BottomNavigationBarItem _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    if (index == 2) {
      return BottomNavigationBarItem(
        icon: GlowingIcon(icon: icon, size: 28),
        label: label,
      );
    } else {
      return BottomNavigationBarItem(icon: Icon(icon), label: label);
    }
  }

  Tween<Offset> _getEnterTween() {
    if (_currentIndex > _previousIndex) {
      return Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero);
    } else {
      return Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero);
    }
  }

  Tween<Offset> _getExitTween() {
    if (_currentIndex > _previousIndex) {
      return Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero);
    } else {
      return Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('coAIRence')),
    body: Stack(
      children: [
        const ShaderBackdrop(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final isEntering = switch (child.key) {
              ValueKey<int>(:final int value) => value == _currentIndex,
              _ => false,
            };
            if (isEntering) {
              final enterTween = _getEnterTween();
              return SlideTransition(
                position: animation.drive(
                  enterTween.chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            } else {
              final exitTween = _getExitTween();
              return SlideTransition(
                position: animation.drive(
                  exitTween.chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            }
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: _getPageForIndex(_currentIndex),
          ),
        ),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
      items: [
        _buildNavItem(context, icon: Icons.home, label: 'Home', index: 0),
        _buildNavItem(
          context,
          icon: Icons.fitness_center,
          label: 'Exercises',
          index: 1,
        ),
        _buildNavItem(
          context,
          icon: Icons.play_circle_fill,
          label: 'Breathe',
          index: 2,
        ),
        _buildNavItem(context, icon: Icons.person, label: 'Profile', index: 3),
        _buildNavItem(
          context,
          icon: Icons.settings,
          label: 'Settings',
          index: 4,
        ),
      ],
    ),
  );
}

class ShaderBackdrop extends StatefulWidget {
  const ShaderBackdrop({super.key});

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
    null => const Center(child: CircularProgressIndicator()),
    final shader => LayoutBuilder(
      builder:
          (context, constraints) => CustomPaint(
            painter: ShaderPainter(
              shader: shader,
              fullSize: Size(constraints.maxWidth, constraints.maxHeight),
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
    ),
  };
}

class ShaderPainter extends CustomPainter {
  ShaderPainter({
    required this.shader,
    required this.fullSize,
  }) : _paint = Paint()..shader = (shader
          ..setFloat(0, fullSize.width)
          ..setFloat(1, fullSize.height)
          ..setFloat(2, 60));
    
  final FragmentShader shader;
  final Size fullSize;
  final Paint _paint;
  
  @override
  void paint(Canvas canvas, Size size) => canvas.drawRect(
      Rect.fromLTWH(0, 0, fullSize.width, fullSize.height),
      _paint,
    );
  
  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) => false;
}

class GlowingIcon extends StatefulWidget {
  const GlowingIcon({required this.icon, required this.size, super.key});

  final IconData icon;
  final double size;

  @override
  State<GlowingIcon> createState() => _GlowingIconState();
}

class _GlowingIconState extends State<GlowingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder:
        (context, child) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onPrimary,
                blurRadius: _animation.value,
                spreadRadius: _animation.value / 2,
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
  );
}

@immutable
class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  bool showButton = true;

  static const simplePattern = <BreathStep>[
    (breathTo: 1.0, duration: Duration(seconds: 5)), // inhale over 5s
    (breathTo: 1.0, duration: Duration(seconds: 2)), // hold for 2s
    (breathTo: 0.0, duration: Duration(seconds: 7)), // exhale over 7s
  ];

  void _handleStartPressed() {
    setState(() => showButton = false);
  }

  void _handleExerciseCompleted() => setState(() => showButton = true);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: Stack(
      children: [
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child:
                showButton
                    ? Center(
                      key: const ValueKey('startButton'),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.onPrimary,
                              spreadRadius: 8,
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(40),
                            elevation: 10,
                          ),
                          onPressed: _handleStartPressed,
                          child: const Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'Breathe',
                              style: TextStyle(fontSize: 34),
                            ),
                          ),
                        ),
                      ),
                    )
                    : BreathGuide(
                      pattern: simplePattern,
                      totalRepetitions: 5,
                      onExerciseCompleted: _handleExerciseCompleted,
                      key: const ValueKey('breathingExercise'),
                    ),
          ),
        ),
      ],
    ),
  );
}

class BreathGuide extends StatefulWidget {
  const BreathGuide({
    required this.pattern,
    required this.totalRepetitions,
    required this.onExerciseCompleted,
    super.key,
  });

  final List<BreathStep> pattern;
  final int totalRepetitions;
  final VoidCallback onExerciseCompleted;

  @override
  State<BreathGuide> createState() => _BreathGuideState();
}

class _BreathGuideState extends State<BreathGuide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<double> _keyPercentages;
  late final List<double> _keyTimes; // Normalized time points (0.0 to 1.0)
  late final double cycleSeconds;
  late final double totalDurationSeconds;

  @override
  void initState() {
    super.initState();
    cycleSeconds = widget.pattern.fold<double>(
      0,
      (prev, step) => prev + step.duration.inMilliseconds / 1000.0,
    );
    totalDurationSeconds = cycleSeconds * widget.totalRepetitions;

    // Pre-calculate key percentages and times for one cycle.
    final percentages = <double>[];
    final times = <double>[];
    double currentTime = 0;

    // Start at 0% (center).
    percentages.add(0);
    times.add(0);
    for (final step in widget.pattern) {
      currentTime += step.duration.inMilliseconds / 1000.0;
      percentages.add(step.breathTo);
      times.add(currentTime);
    }
    final normalizedTimes = times.map((t) => t / cycleSeconds).toList();

    _keyPercentages = percentages;
    _keyTimes = normalizedTimes;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (totalDurationSeconds * 1000).round()),
    )..addListener(() => setState(() {}));
    _controller.forward().whenComplete(() {
      if (getCurrentRepetition() >= widget.totalRepetitions) {
        _controller.stop();
        widget.onExerciseCompleted();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double getCurrentBreathPercentage() {
    final overallProgress = _controller.value;
    final cycleProgress = (overallProgress * widget.totalRepetitions) % 1.0;

    var index = 0;
    while (index < _keyTimes.length - 1 &&
        cycleProgress > _keyTimes[index + 1]) {
      index++;
    }
    if (index >= _keyTimes.length - 1) return _keyPercentages.last;

    final t1 = _keyTimes[index];
    final t2 = _keyTimes[index + 1];
    final v1 = _keyPercentages[index];
    final v2 = _keyPercentages[index + 1];

    var localProgress = (cycleProgress - t1) / (t2 - t1);

    localProgress = Curves.easeInOut.transform(localProgress);

    return v1 + (v2 - v1) * localProgress;
  }

  int getCurrentRepetition() =>
      (_controller.value * widget.totalRepetitions).floor() + 1;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder:
        (context, constraints) => Stack(
          children: [
            // Backdrop showing the full breathing pattern.
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: BreathPatternBackdrop(
                context,
                keyPercentages: _keyPercentages,
                keyTimes: _keyTimes,
              ),
            ),
            // The active animation on top.
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _BreathPainter(
                context,
                breathPercent: getCurrentBreathPercentage(),
              ),
            ),
            Center(
              child: AnimatedSwitcher(
                duration: Durations.long1,
                transitionBuilder:
                    (Widget child, Animation<double> animation) =>
                        FadeTransition(opacity: animation, child: child),
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  key: ValueKey<int>(getCurrentRepetition()),
                  child: Text(
                    switch (1 +
                        widget.totalRepetitions -
                        getCurrentRepetition()) {
                      0 => '',
                      final int i => '$i',
                    },
                    style: TextStyle(
                      fontSize: 1000,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
  );
}

class _BreathPainter extends CustomPainter {
  _BreathPainter(BuildContext context, {required this.breathPercent})
    : _paint =
          Paint()
            ..color = Theme.of(context).colorScheme.primary
            ..strokeWidth = 4.0
            ..strokeCap = StrokeCap.round;
  final double breathPercent;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final offset = centerX * breathPercent;

    canvas
      ..drawLine(
        Offset(centerX - offset, 0),
        Offset(centerX - offset, size.height),
        _paint,
      )
      ..drawLine(
        Offset(centerX + offset, 0),
        Offset(centerX + offset, size.height),
        _paint,
      );
  }

  @override
  bool shouldRepaint(_BreathPainter oldDelegate) =>
      oldDelegate.breathPercent != breathPercent;
}

/// CustomPainter that draws the full, expected breathing pattern as a backdrop.
class BreathPatternBackdrop extends CustomPainter {
  BreathPatternBackdrop(
    BuildContext context, {
    required this.keyPercentages,
    required this.keyTimes,
    this.tension = 0.42,
  }) : _paint =
           Paint()
             ..color = Theme.of(context).colorScheme.onPrimary
             ..strokeWidth = 2.0
             ..style = PaintingStyle.stroke;
  final List<double> keyPercentages;
  final List<double> keyTimes;
  final double tension;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the center horizontal.
    final centerX = size.width / 2;

    // Create paths for left and right lines.
    final leftPath = _createPath(
      centerX,
      size,
      (centerX, percent) => centerX - centerX * percent,
    );
    final rightPath = _createPath(
      centerX,
      size,
      (centerX, percent) => centerX + centerX * percent,
    );

    // Draw the two paths.
    canvas.drawPath(leftPath, _paint);
    canvas.drawPath(rightPath, _paint);
  }

  Path _createPath(
    double centerX,
    Size size,
    double Function(double, double) calculateX,
  ) {
    final path = Path()..moveTo(centerX, 0);
    // The keyTimes map to vertical positions along the height.
    for (var i = 0; i < keyPercentages.length - 1; i++) {
      final percent = keyPercentages[i];
      final nextPercent = keyPercentages[i + 1];
      final timeFactor = keyTimes[i];
      final nextTimeFactor = keyTimes[i + 1];

      final x = calculateX(centerX, percent);
      final y = size.height * timeFactor;
      final nextX = calculateX(centerX, nextPercent);
      final nextY = size.height * nextTimeFactor;

      final controlPoint1X = x;
      final controlPoint1Y = y + tension * (nextY - y);
      final controlPoint2X = nextX;
      final controlPoint2Y = nextY - tension * (nextY - y);

      path.cubicTo(
        controlPoint1X,
        controlPoint1Y,
        controlPoint2X,
        controlPoint2Y,
        nextX,
        nextY,
      );
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant BreathPatternBackdrop oldDelegate) {
    return false;
  }
}

typedef BreathStep = ({double breathTo, Duration duration});
