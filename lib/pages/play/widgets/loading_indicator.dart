import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable loading indicator widget with customizable appearance
///
/// Features:
/// - Adaptive sizing based on screen dimensions
/// - Consistent branding with app colors
/// - Optimized for 60fps animations
class LoadingIndicator extends StatelessWidget {
  /// Creates a loading indicator
  ///
  /// [size] - The size of the loading animation (default: 50)
  /// [color] - The color of the loading animation (default: AppColors.textEnabledColor)
  const LoadingIndicator({
    this.size = 50.0,
    this.color = AppColors.textEnabledColor,
    super.key,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.waveDots(
        color: color,
        size: size,
      ),
    );
  }
}
