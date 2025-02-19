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

  Widget _getPageForIndex(int index) {
    return switch (index) {
      0 => const Center(
          child: Text('Home Page', style: TextStyle(fontSize: 24)),
        ),
      1 => const Center(
          child: Text('Exercices Page', style: TextStyle(fontSize: 24)),
        ),
      2 => const StartPage(),
      3 => const Center(
          child: Text('Profile Page', style: TextStyle(fontSize: 24)),
        ),
      4 => const Center(
          child: Text('Settings Page', style: TextStyle(fontSize: 24)),
        ),
      _ => const StartPage()
    };
  }

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
      return BottomNavigationBarItem(
        icon: Icon(icon),
        label: label,
      );
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
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final isEntering =
                (child.key as ValueKey<int>).value == _currentIndex;
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
            _buildNavItem(context,
                icon: Icons.fitness_center, label: 'Exercices', index: 1),
            _buildNavItem(context,
                icon: Icons.play_circle_fill, label: 'Start', index: 2),
            _buildNavItem(context,
                icon: Icons.person, label: 'Profile', index: 3),
            _buildNavItem(context,
                icon: Icons.settings, label: 'Settings', index: 4),
          ],
        ),
      );
}

class GlowingIcon extends StatefulWidget {
  final IconData icon;
  final double size;

  const GlowingIcon({
    super.key,
    required this.icon,
    required this.size,
  });

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
    _animation = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        builder: (context, child) => Container(
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

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
          onPressed: () =>
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Start pressed!'),
          )),
          child: const Text(
            'Start',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
