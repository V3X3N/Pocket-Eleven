// File: widgets/common/app_title.dart
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// **Reusable app title with modern styling and optional underline**
///
/// Creates a stylized title with gradient underline decoration.
/// Responsive font sizing and optimized rendering.
///
/// **Parameters:**
/// - [title] - The title text to display (required)
/// - [fontSize] - Title font size (default: 32)
/// - [fontWeight] - Title font weight (default: bold)
/// - [color] - Title text color (default: AppColors.textEnabledColor)
/// - [letterSpacing] - Letter spacing (default: 2)
/// - [showUnderline] - Show gradient underline (default: false)
/// - [underlineColors] - Gradient colors for underline
/// - [underlineWidth] - Width of underline (default: 80)
/// - [underlineHeight] - Height of underline (default: 3)
///
/// **Usage:**
/// ```dart
/// AppTitle(
///   title: 'MY APP',
///   fontSize: 36,
///   showUnderline: true,
/// )
/// ```
class AppTitle extends StatelessWidget {
  /// The title text to display
  final String title;

  /// Font size of the title
  final double fontSize;

  /// Font weight of the title
  final FontWeight fontWeight;

  /// Text color
  final Color color;

  /// Letter spacing
  final double letterSpacing;

  /// Whether to show underline decoration
  final bool showUnderline;

  /// Colors for gradient underline
  final List<Color>? underlineColors;

  /// Width of the underline
  final double underlineWidth;

  /// Height of the underline
  final double underlineHeight;

  const AppTitle({
    super.key,
    required this.title,
    this.fontSize = 32,
    this.fontWeight = FontWeight.bold,
    this.color = AppColors.textEnabledColor,
    this.letterSpacing = 2,
    this.showUnderline = false,
    this.underlineColors,
    this.underlineWidth = 80,
    this.underlineHeight = 3,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive font size based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveFontSize = _getResponsiveFontSize(screenWidth);

    return RepaintBoundary(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: responsiveFontSize,
              fontWeight: fontWeight,
              color: color,
              letterSpacing: letterSpacing,
            ),
            textAlign: TextAlign.center,
          ),
          if (showUnderline) ...[
            const SizedBox(height: 12),
            _buildUnderline(context),
          ],
        ],
      ),
    );
  }

  Widget _buildUnderline(BuildContext context) {
    final colors = underlineColors ??
        [
          AppColors.blueColor,
          AppColors.playerPurple,
          Colors.transparent,
        ];

    // Responsive underline width
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveWidth = _getResponsiveUnderlineWidth(screenWidth);

    return Container(
      height: underlineHeight,
      width: responsiveWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(underlineHeight / 2),
      ),
    );
  }

  double _getResponsiveFontSize(double screenWidth) {
    if (screenWidth > 600) return fontSize;
    if (screenWidth > 400) return fontSize * 0.85;
    return fontSize * 0.75;
  }

  double _getResponsiveUnderlineWidth(double screenWidth) {
    if (screenWidth > 600) return underlineWidth;
    if (screenWidth > 400) return underlineWidth * 0.85;
    return underlineWidth * 0.75;
  }
}
