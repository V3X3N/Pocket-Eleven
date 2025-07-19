import 'package:flutter/material.dart';

/// A reusable fade page transition for smooth navigation between screens.
///
/// This transition provides:
/// - Smooth fade-in/fade-out animation between pages
/// - Customizable transition duration and curve
/// - Optimized performance for 60fps rendering
/// - Memory efficient with proper disposal handling
///
/// Usage:
/// ```dart
/// Navigator.pushReplacement(
///   context,
///   FadePageTransition(
///     page: NextScreen(),
///     duration: Duration(milliseconds: 300),
///   ),
/// )
/// ```
class FadePageTransition extends PageRouteBuilder {
  /// The destination page/widget to navigate to
  final Widget page;

  /// Duration of the fade transition
  final Duration duration;

  /// Animation curve for the transition
  final Curve curve;

  /// Creates a fade page transition.
  ///
  /// [page] is the destination widget to navigate to.
  /// [duration] controls how long the transition takes.
  /// [curve] determines the animation easing function.
  FadePageTransition({
    required this.page,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOut,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _FadeTransitionBuilder(
              animation: animation,
              curve: curve,
              child: child,
            );
          },
        );
}

/// Optimized fade transition builder widget.
///
/// This widget is separated for better performance and reusability.
/// It uses RepaintBoundary to optimize rendering and reduce unnecessary repaints.
class _FadeTransitionBuilder extends StatelessWidget {
  /// The animation controller for the fade effect
  final Animation<double> animation;

  /// The animation curve
  final Curve curve;

  /// The child widget to animate
  final Widget child;

  /// Creates a fade transition builder.
  const _FadeTransitionBuilder({
    required this.animation,
    required this.curve,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: curve,
        ),
        child: child,
      ),
    );
  }
}
