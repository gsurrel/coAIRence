import 'package:coairence/ui/theme/pattern_tag_style.dart';
import 'package:coairence/ui/viewmodels/breath_page_provider.dart';
import 'package:coairence/ui/viewmodels/main_scaffold_provider.dart';
import 'package:coairence/ui/views/animated_backdrop.dart';
import 'package:coairence/ui/views/breathe_page.dart';
import 'package:coairence/ui/views/breathes_library.dart';
import 'package:coairence/ui/views/home_page.dart';
import 'package:coairence/ui/views/settings_page.dart';
import 'package:coairence/ui/widgets/profile_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 2;
  int _previousIndex = 2;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    final initialTab = ref.read(mainScaffoldTabProvider);
    _currentIndex = initialTab;
    _previousIndex = initialTab;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation =
        Tween<double>(
          begin: _previousIndex.toDouble(),
          end: _currentIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
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
      _animation =
          Tween<double>(
            begin: _previousIndex.toDouble(),
            end: _currentIndex.toDouble(),
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeInOut,
            ),
          );
    });
    _animationController.forward(from: 0);
    ref.read(mainScaffoldTabProvider.notifier).tab = targetIndex;
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

  static const List<Widget> _pages = [
    HomePage(),
    BreathesLibraryPage(),
    BreathePage(),
    ProfilePage(),
    SettingsPage(),
  ];

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    if (s.toLowerCase() == 'hrv') return 'HRV';
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(mainScaffoldTabProvider, (previous, next) {
      if (next != _currentIndex) {
        setState(() {
          _previousIndex = _currentIndex;
          _currentIndex = next;
          _animation =
              Tween<double>(
                begin: _previousIndex.toDouble(),
                end: _currentIndex.toDouble(),
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeInOut,
                ),
              );
        });
        _animationController.forward(from: 0);
      }
    });

    final currentTab = ref.watch(mainScaffoldTabProvider);
    final filterTags = ref.watch(
      breathPageProvider.select((s) => s.filterTags),
    );
    final showFilterBadge = currentTab == 1 && filterTags.isNotEmpty;

    return Scaffold(
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
        actions: [
          if (showFilterBadge)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(
                      filterTags.first.icon,
                      size: 16,
                      color: filterTags.first.onColor(
                        Theme.of(context).colorScheme,
                      ),
                    ),
                    Text(
                      _capitalize(filterTags.first.name),
                      style: TextStyle(
                        color: filterTags.first.onColor(
                          Theme.of(context).colorScheme,
                        ),
                      ),
                    ),
                    const Icon(Icons.close, size: 16),
                  ],
                ),
                backgroundColor: filterTags.first.color(
                  Theme.of(context).colorScheme,
                ),
                onPressed: () {
                  ref.read(breathPageProvider.notifier).setFilterTags(const []);
                },
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBackdrop(animation: _animation),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
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
              child:
                  _pages.elementAtOrNull(_currentIndex) ?? const BreathePage(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.air), label: 'Patterns'),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: 'Breathe',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
