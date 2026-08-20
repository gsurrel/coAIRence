import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/ui/viewmodels/breath_page_provider.dart';
import 'package:coairence/ui/viewmodels/main_scaffold_provider.dart';
import 'package:coairence/ui/views/animated_backdrop.dart';
import 'package:coairence/ui/views/breathe_page.dart';
import 'package:coairence/ui/views/breathes_library_page.dart';
import 'package:coairence/ui/views/home_page.dart';
import 'package:coairence/ui/views/profile_page.dart';
import 'package:coairence/ui/views/settings_page.dart';
import 'package:coairence/ui/widgets/pattern_tag_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;

  late AnimationController _pageAnimationController;
  late Animation<double> _pageAnimation;
  late AnimationController _navHideController;
  late Animation<double> _navHideAnimation;

  @override
  void initState() {
    super.initState();
    final initialTab = ref.read(mainScaffoldTabProvider);
    _currentIndex = initialTab;
    _previousIndex = initialTab;
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pageAnimation =
        Tween<double>(
          begin: _previousIndex.toDouble(),
          end: _currentIndex.toDouble(),
        ).animate(
          CurvedAnimation(
            parent: _pageAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    _navHideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: 1,
    );
    _navHideAnimation = CurvedAnimation(
      parent: _navHideController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _navHideController.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int targetIndex) {
    if (targetIndex == _currentIndex) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = targetIndex;
      _pageAnimation =
          Tween<double>(
            begin: _previousIndex.toDouble(),
            end: _currentIndex.toDouble(),
          ).animate(
            CurvedAnimation(
              parent: _pageAnimationController,
              curve: Curves.easeInOut,
            ),
          );
    });
    _pageAnimationController.forward(from: 0);
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

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(mainScaffoldTabProvider, (previous, next) {
      if (next != _currentIndex) {
        setState(() {
          _previousIndex = _currentIndex;
          _currentIndex = next;
          _pageAnimation =
              Tween<double>(
                begin: _previousIndex.toDouble(),
                end: _currentIndex.toDouble(),
              ).animate(
                CurvedAnimation(
                  parent: _pageAnimationController,
                  curve: Curves.easeInOut,
                ),
              );
        });
        _pageAnimationController.forward(from: 0);
      }
    });

    ref.listen<bool>(
      breathPageProvider.select((s) => s.isExercising),
      (previous, next) {
        if (next) {
          _navHideController.reverse(); // Hide
        } else {
          _navHideController.forward(); // Show
        }
      },
    );

    final currentTab = ref.watch(mainScaffoldTabProvider);
    final filterTags = ref.watch(
      breathPageProvider.select((s) => s.filterTags),
    );
    final activeFilter = filterTags.isNotEmpty ? filterTags.first : null;

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
          if (currentTab == 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final tag in PatternTag.values)
                      if (activeFilter == null || activeFilter == tag)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          child: PatternTagIcon(
                            tag,
                            expanded: activeFilter == tag,
                            onTap: activeFilter == tag
                                ? () => ref
                                      .read(breathPageProvider.notifier)
                                      .setFilterTags(const [])
                                : () => ref
                                      .read(breathPageProvider.notifier)
                                      .setFilterTags([tag]),
                          ),
                        ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedBackdrop(animation: _pageAnimation),
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
                    _pages.elementAtOrNull(_currentIndex) ?? const HomePage(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizeTransition(
        sizeFactor: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _navHideAnimation,
            curve: Curves.easeInOut,
          ),
        ),
        alignment: AlignmentGeometry.bottomCenter,
        child: BottomNavigationBar(
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
      ),
    );
  }
}
