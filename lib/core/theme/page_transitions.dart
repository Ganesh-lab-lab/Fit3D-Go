import 'dart:ui';
import 'package:flutter/material.dart';

/// Soft fade and blur screen route transition inspired by OriginOS
class GlassPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  GlassPageRoute({
    required this.page,
    super.settings,
    Duration duration = const Duration(milliseconds: 320),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return AnimatedBuilder(
              animation: curved,
              builder: (context, childWidget) {
                final blurVal = (1.0 - curved.value) * 12.0;
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurVal > 0 ? blurVal : 0.001,
                    sigmaY: blurVal > 0 ? blurVal : 0.001,
                  ),
                  child: FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
                      child: childWidget,
                    ),
                  ),
                );
              },
              child: child,
            );
          },
        );
}

/// Global PageTransitionsBuilder for MaterialApp theme
class GlassPageTransitionsBuilder extends PageTransitionsBuilder {
  const GlassPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}
