import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable loading state widget that displays animated loading indicator
/// with customizable message and modern gradient background.
///
/// Features:
/// - Smooth wave dots animation
/// - Gradient background with opacity
/// - Customizable loading message
/// - Optimized for 60fps performance
class LoadingStateWidget extends StatelessWidget {
  /// Creates a loading state widget.
  ///
  /// [message] - The loading message to display (required)
  /// [animationSize] - Size of the loading animation (default: 50.0)
  const LoadingStateWidget({
    super.key,
    required this.message,
    this.animationSize = 50.0,
  });

  /// The message to display below the loading animation
  final String message;

  /// The size of the loading animation
  final double animationSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.hoverColor.withValues(alpha: 0.1),
            AppColors.hoverColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              child: LoadingAnimationWidget.waveDots(
                color: AppColors.textEnabledColor,
                size: animationSize,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textEnabledColor.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
