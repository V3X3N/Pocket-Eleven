import 'package:flutter/material.dart';

/// A reusable animated card widget with glassmorphism effect and gradient text logo.
///
/// This widget provides a modern, responsive container with:
/// - Glassmorphism visual effects with blur and transparency
/// - Gradient text rendering for the title
/// - Responsive sizing based on screen dimensions
/// - Optimized for 60fps rendering with RepaintBoundary
///
/// Usage:
/// ```dart
/// AnimatedLogoCard(
///   title: 'MY APP\nNAME',
///   child: MyContentWidget(),
/// )
/// ```
class AnimatedLogoCard extends StatelessWidget {
  /// The title text to display with gradient effect
  final String title;

  /// The child widget to display below the title
  final Widget child;

  /// Optional custom text style for the title
  final TextStyle? titleStyle;

  /// Optional custom gradient colors for the title
  final List<Color>? gradientColors;

  /// Creates an animated logo card widget.
  ///
  /// [title] is required and will be rendered with gradient effect.
  /// [child] is the widget displayed below the title.
  /// [titleStyle] allows custom styling (fontSize will be responsive if not provided).
  /// [gradientColors] allows custom gradient colors for the title.
  const AnimatedLogoCard({
    super.key,
    required this.title,
    required this.child,
    this.titleStyle,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final logoSize = isTablet ? 48.0 : 40.0;
    final cardPadding = isTablet ? 40.0 : 32.0;

    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        margin: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.1,
        ),
        decoration: _buildGlassmorphismDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGradientTitle(logoSize),
            const SizedBox(height: 32),
            SizedBox(
              height: 60,
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the glassmorphism decoration for the card
  BoxDecoration _buildGlassmorphismDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.05),
        ],
        stops: const [0.0, 1.0],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  /// Builds the gradient title text
  Widget _buildGradientTitle(double fontSize) {
    final effectiveStyle = titleStyle ??
        TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 2,
          height: 1.1,
        );

    final effectiveColors = gradientColors ??
        [
          Colors.white,
          Colors.white.withValues(alpha: 0.8),
        ];

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: effectiveColors,
      ).createShader(bounds),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: effectiveStyle,
      ),
    );
  }
}
