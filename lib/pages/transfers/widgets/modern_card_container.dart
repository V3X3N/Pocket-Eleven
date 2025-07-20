import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable modern card container widget with consistent styling.
///
/// Features:
/// - Modern design with shadows and rounded corners
/// - Customizable margin and padding
/// - Consistent color scheme using AppColors
/// - Responsive design for different screen sizes
/// - Optimized for performance with RepaintBoundary
class ModernCardContainer extends StatelessWidget {
  /// Creates a modern card container.
  ///
  /// [child] - The widget to display inside the card (required)
  /// [margin] - Margin around the card (default: EdgeInsets.all(16))
  /// [borderRadius] - Border radius of the card (default: 12.0)
  const ModernCardContainer({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.all(16),
    this.borderRadius = 12.0,
  });

  /// The widget to display inside the card
  final Widget child;

  /// Margin around the card
  final EdgeInsetsGeometry margin;

  /// Border radius of the card
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
