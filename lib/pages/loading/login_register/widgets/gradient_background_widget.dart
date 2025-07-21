// File: widgets/common/gradient_background.dart
import 'package:flutter/material.dart';

/// **Reusable gradient background container**
///
/// Creates a smooth gradient background that adapts to screen size.
/// Optimized for 60fps rendering with RepaintBoundary.
///
/// **Parameters:**
/// - [colors] - List of colors for the gradient (required)
/// - [child] - Widget to display over the gradient (required)
/// - [begin] - Gradient start alignment (default: topLeft)
/// - [end] - Gradient end alignment (default: bottomRight)
///
/// **Usage:**
/// ```dart
/// GradientBackground(
///   colors: [Colors.blue, Colors.purple],
///   child: YourContentWidget(),
/// )
/// ```
class GradientBackground extends StatelessWidget {
  /// List of gradient colors
  final List<Color> colors;

  /// Child widget to display over gradient
  final Widget child;

  /// Gradient start point
  final AlignmentGeometry begin;

  /// Gradient end point
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.colors,
    required this.child,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  }) : assert(
            colors.length >= 2, 'At least 2 colors are required for gradient');

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: colors,
          ),
        ),
        child: child,
      ),
    );
  }
}
