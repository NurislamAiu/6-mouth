import 'package:flutter/material.dart';

class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 300);
  static const Curve curve = Curves.easeOutCubic;

  static Widget fadeSlideTransition(
    Widget child,
    Animation<double> animation, {
    Offset begin = const Offset(0, 0.025),
  }) {
    final curved = CurvedAnimation(parent: animation, curve: curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}

class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AppMotion.fadeSlideTransition(child, animation);
  }
}
