import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../widgets/app_bottom_nav.dart';
import 'coach_screen.dart';
import 'me_screen.dart';
import 'progress_screen.dart';
import 'timeline_screen.dart';
import 'today_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    TodayScreen(),
    ProgressScreen(),
    TimelineScreen(),
    CoachScreen(),
    MeScreen(),
  ];

  static const _navItems = [
    AppBottomNavItem(
      label: 'TODAY',
      icon: Icons.today_outlined,
      activeIcon: Icons.today,
    ),
    AppBottomNavItem(
      label: 'LEVEL',
      icon: Icons.bolt_outlined,
      activeIcon: Icons.bolt,
    ),
    AppBottomNavItem(
      label: 'PLAN',
      icon: Icons.timeline_outlined,
      activeIcon: Icons.timeline,
    ),
    AppBottomNavItem(
      label: 'COACH',
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology,
    ),
    AppBottomNavItem(
      label: 'ME',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AnimatedIndexedStack(index: _index, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        items: _navItems,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _AnimatedIndexedStack extends StatelessWidget {
  const _AnimatedIndexedStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(children.length, (childIndex) {
        final selected = childIndex == index;
        return IgnorePointer(
          ignoring: !selected,
          child: TickerMode(
            enabled: selected,
            child: AnimatedOpacity(
              duration: AppMotion.normal,
              curve: AppMotion.curve,
              opacity: selected ? 1 : 0,
              child: AnimatedSlide(
                duration: AppMotion.normal,
                curve: AppMotion.curve,
                offset: selected ? Offset.zero : const Offset(0.02, 0),
                child: children[childIndex],
              ),
            ),
          ),
        );
      }),
    );
  }
}
