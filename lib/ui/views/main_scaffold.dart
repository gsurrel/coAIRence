import 'package:coairence/ui/views/animated_backdrop.dart';
import 'package:coairence/ui/views/breathe_page.dart';
import 'package:coairence/ui/views/exercises_page.dart';
import 'package:flutter/material.dart';

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
    ExercisesPage(),
    BreathePage(),
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
            child: _pages.elementAtOrNull(_currentIndex) ?? const BreathePage(),
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
