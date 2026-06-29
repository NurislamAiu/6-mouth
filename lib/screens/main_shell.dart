import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'coach_screen.dart';
import 'me_screen.dart';
import 'progress_screen.dart';
import 'today_screen.dart';
import 'tracker_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    TodayScreen(),
    TrackerScreen(),
    ProgressScreen(),
    CoachScreen(),
    MeScreen(),
  ];

  static const _navItems = [
    AppBottomNavItem(
      label: 'СЕГОДНЯ',
      icon: Icons.today_outlined,
      activeIcon: Icons.today,
    ),
    AppBottomNavItem(
      label: 'ТРЕКЕР',
      icon: Icons.checklist_outlined,
      activeIcon: Icons.checklist,
    ),
    AppBottomNavItem(
      label: 'ПРОГРЕСС',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
    ),
    AppBottomNavItem(
      label: 'КОУЧ',
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology,
    ),
    AppBottomNavItem(
      label: 'Я',
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

class _AnimatedIndexedStack extends StatefulWidget {
  const _AnimatedIndexedStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_AnimatedIndexedStack> createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<_AnimatedIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  int _current = 0;
  int _previous = 0;

  static const _duration = Duration(milliseconds: 320);
  static const _curve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();
    _current = widget.index;
    _previous = widget.index;
    _controller = AnimationController(vsync: this, duration: _duration);
    _opacity = CurvedAnimation(parent: _controller, curve: _curve);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.018),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: _curve));
    _controller.value = 1;
  }

  @override
  void didUpdateWidget(_AnimatedIndexedStack old) {
    super.didUpdateWidget(old);
    if (widget.index != old.index) {
      _previous = old.index;
      _current = widget.index;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.children.length, (i) {
        final isCurrent = i == _current;
        final isPrevious = i == _previous;
        if (!isCurrent && !isPrevious) {
          return IgnorePointer(
            child: TickerMode(
              enabled: false,
              child: Opacity(opacity: 0, child: widget.children[i]),
            ),
          );
        }
        if (isPrevious && !isCurrent) {
          return IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, child) => Opacity(
                opacity: (1 - _opacity.value).clamp(0.0, 1.0),
                child: child,
              ),
              child: TickerMode(
                enabled: false,
                child: widget.children[i],
              ),
            ),
          );
        }
        // current screen
        return IgnorePointer(
          ignoring: false,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, child) => Opacity(
              opacity: _opacity.value,
              child: SlideTransition(position: _slide, child: child),
            ),
            child: TickerMode(
              enabled: true,
              child: widget.children[i],
            ),
          ),
        );
      }),
    );
  }
}
