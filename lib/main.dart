import 'package:flutter/material.dart';

void main() => runApp(const CoAIRenceApp());

class CoAIRenceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'coAIRence',
    theme: ThemeData(
      colorSchemeSeed: Colors.purple,
      brightness: Brightness.dark,
    ),
    home: const MainScaffold(),
  );

  const CoAIRenceApp({super.key});
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
    0 => const Center(child: Text('Home', style: TextStyle(fontSize: 24))),
    1 => const Center(child: Text('Exercices', style: TextStyle(fontSize: 24))),
    2 => const StartPage(),
    3 => const Center(child: Text('Profile', style: TextStyle(fontSize: 24))),
    4 => const Center(child: Text('Settings', style: TextStyle(fontSize: 24))),
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
    body: AnimatedSwitcher(
      duration: Durations.medium1,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final isEntering = (child.key as ValueKey<int>).value == _currentIndex;
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
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
      items: [
        _buildNavItem(context, icon: Icons.home, label: 'Home', index: 0),
        _buildNavItem(
          context,
          icon: Icons.fitness_center,
          label: 'Exercices',
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

class GlowingIcon extends StatefulWidget {
  const GlowingIcon({super.key, required this.icon, required this.size});

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
      duration: Durations.extralong4,
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
    body: Stack(
      children: [
        Center(
          child: AnimatedSwitcher(
            duration: Durations.medium1,
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
                            padding: EdgeInsets.all(32.0),
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
    super.key,
    required this.pattern,
    required this.totalRepetitions,
    required this.onExerciseCompleted,
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
      0.0,
      (prev, step) => prev + step.duration.inMilliseconds / 1000.0,
    );
    totalDurationSeconds = cycleSeconds * widget.totalRepetitions;

    // Pre-calculate key percentages and times for one cycle.
    List<double> percentages = [];
    List<double> times = [];
    double currentTime = 0.0;

    // Start at 0% (center).
    percentages.add(0.0);
    times.add(0.0);
    for (var step in widget.pattern) {
      currentTime += step.duration.inMilliseconds / 1000.0;
      percentages.add(step.breathTo);
      times.add(currentTime);
    }
    List<double> normalizedTimes = times.map((t) => t / cycleSeconds).toList();

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
    double overallProgress = _controller.value;
    double cycleProgress = (overallProgress * widget.totalRepetitions) % 1.0;

    int index = 0;
    while (index < _keyTimes.length - 1 &&
        cycleProgress > _keyTimes[index + 1]) {
      index++;
    }
    if (index >= _keyTimes.length - 1) return _keyPercentages.last;

    double t1 = _keyTimes[index];
    double t2 = _keyTimes[index + 1];
    double v1 = _keyPercentages[index];
    double v2 = _keyPercentages[index + 1];

    double localProgress = (cycleProgress - t1) / (t2 - t1);

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
                      ).colorScheme.primary.withValues(alpha: 0.1),
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
  final double breathPercent;
  final Paint _paint;

  _BreathPainter(context, {required this.breathPercent})
    : _paint =
          Paint()
            ..color = Theme.of(context).colorScheme.primary
            ..strokeWidth = 4.0
            ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double offset = centerX * breathPercent;

    canvas.drawLine(
      Offset(centerX - offset, 0),
      Offset(centerX - offset, size.height),
      _paint,
    );
    canvas.drawLine(
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
  final List<double> keyPercentages;
  final List<double> keyTimes;
  final double tension;
  final Paint _paint;

  BreathPatternBackdrop(
    context, {
    required this.keyPercentages,
    required this.keyTimes,
    this.tension = 0.35,
  }) : _paint =
           Paint()
             ..color = Theme.of(context).colorScheme.onPrimary
             ..strokeWidth = 2.0
             ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the center horizontal.
    double centerX = size.width / 2;

    // Create paths for left and right lines.
    Path leftPath = _createPath(
      centerX,
      size,
      (centerX, percent) => centerX - centerX * percent,
    );
    Path rightPath = _createPath(
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
    Path path = Path()..moveTo(centerX, 0);
    // The keyTimes map to vertical positions along the height.
    for (int i = 0; i < keyPercentages.length - 1; i++) {
      double percent = keyPercentages[i];
      double nextPercent = keyPercentages[i + 1];
      double timeFactor = keyTimes[i];
      double nextTimeFactor = keyTimes[i + 1];

      double x = calculateX(centerX, percent);
      double y = size.height * timeFactor;
      double nextX = calculateX(centerX, nextPercent);
      double nextY = size.height * nextTimeFactor;

      double controlPoint1X = x;
      double controlPoint1Y = y + tension * (nextY - y);
      double controlPoint2X = nextX;
      double controlPoint2Y = nextY - tension * (nextY - y);

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
