import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable container widget with consistent app styling
///
/// Features:
/// - Responsive margins and padding
/// - Consistent shadow and border styling
/// - Customizable background colors
/// - Modern rounded corners
class AppContainer extends StatelessWidget {
  /// Creates an app container
  ///
  /// [child] - The widget to be contained
  /// [backgroundColor] - Background color of the container
  /// [borderColor] - Border color of the container
  /// [margin] - External margin (if null, uses responsive default)
  /// [padding] - Internal padding (if null, uses responsive default)
  /// [borderRadius] - Corner radius (default: 12)
  const AppContainer({
    required this.child,
    this.backgroundColor = AppColors.hoverColor,
    this.borderColor = AppColors.borderColor,
    this.margin,
    this.padding,
    this.borderRadius = 12.0,
    super.key,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final defaultMargin = screenWidth * 0.04;
    final defaultPadding = screenWidth * 0.02;

    return Container(
      margin: margin ?? EdgeInsets.all(defaultMargin),
      padding: padding ?? EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
