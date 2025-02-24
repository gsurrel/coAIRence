import 'dart:math';
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

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 2;
  int _previousIndex = 2;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: _previousIndex.toDouble(),
      end: _currentIndex.toDouble(),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int targetIndex) {
    if (targetIndex == _currentIndex) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = targetIndex;
      _animation = Tween<double>(
        begin: _previousIndex.toDouble(),
        end: _currentIndex.toDouble(),
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
    });
    _animationController.forward(from: 0);
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

  static const _pages = [
    Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Exercises Page', style: TextStyle(fontSize: 24))),
    StartPage(),
    Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Settings Page', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'co',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: 'AIR',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w300,
              ),
            ),
            TextSpan(
              text: 'ence',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
    body: Stack(
      children: [
        AnimatedBackdrop(animation: _animation),
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
          child: Container(
            key: ValueKey<int>(_currentIndex),
            child: _pages.elementAtOrNull(_currentIndex) ?? const StartPage(),
          ),
        ),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Exercises',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_fill),
          label: 'Start',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    ),
  );
}

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

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Stack(
        children: [
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: switch (showButton) {
                true => Center(
                  key: const ValueKey('startButton'),
                  child: FittedBox(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.all(30),
                      ),
                      onPressed: () => setState(() => showButton = false),
                      child: const Padding(
                        padding: EdgeInsets.all(30),
                        child: Text('Start', style: TextStyle(fontSize: 34)),
                      ),
                    ),
                  ),
                ),
                false => BreathGuide(
                  pattern: simplePattern,
                  totalRepetitions: 5,
                  onExerciseCompleted: () => setState(() => showButton = true),
                  key: const ValueKey('breathingExercise'),
                ),
              },
            ),
          ),
        ],
      ),
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
  late final Duration cycleDuration;
  late final Duration totalDuration;

  @override
  void initState() {
    super.initState();
    cycleDuration = widget.pattern.fold<Duration>(
      Duration.zero,
      (prev, step) => prev + step.duration,
    );
    totalDuration = cycleDuration * widget.totalRepetitions;

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
    final normalizedTimes =
        times.map((t) => t / cycleDuration.inSeconds).toList();

    _keyPercentages = percentages;
    _keyTimes = normalizedTimes;

    _controller = AnimationController(vsync: this, duration: totalDuration)
      ..addListener(() => setState(() {}));
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

  double getCycleProgress() =>
      (_controller.value * widget.totalRepetitions) % 1.0;

  double getCurrentBreathPercentage() {
    var index = 0;
    while (index < _keyTimes.length - 1 &&
        getCycleProgress() > _keyTimes[index + 1]) {
      index++;
    }
    if (index >= _keyTimes.length - 1) return _keyPercentages.last;

    final t1 = _keyTimes[index];
    final t2 = _keyTimes[index + 1];
    final v1 = _keyPercentages[index];
    final v2 = _keyPercentages[index + 1];

    var localProgress = (getCycleProgress() - t1) / (t2 - t1);

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
                cycleProgress: getCycleProgress(),
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
                      ).colorScheme.primary.withValues(alpha: 0.2),
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
  _BreathPainter(
    BuildContext context, {
    required this.cycleProgress,
    required this.breathPercent,
  }) : _paintFill =
           Paint()
             ..color = Theme.of(context).colorScheme.primary.withAlpha(150),
       _paintBorder =
           Paint()
             ..color = Theme.of(context).colorScheme.primary
             ..strokeWidth = 2.0
             ..strokeCap = StrokeCap.round
             ..style = PaintingStyle.stroke;

  final double breathPercent;
  final double cycleProgress;
  final Paint _paintFill;
  final Paint _paintBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final offset = centerX * breathPercent;
    final height = cycleProgress * size.height;
    final lipSize = sqrt(offset * 4);

    // Draw the path on the canvas
    final path =
        Path()
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

    canvas
      ..drawPath(path, _paintFill)
      ..drawPath(path, _paintBorder);
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
    canvas
      ..drawPath(leftPath, _paint)
      ..drawPath(rightPath, _paint);
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
