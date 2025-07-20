import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable loading overlay widget that can be used throughout the app.
///
/// This widget provides a consistent loading experience with customizable
/// animation type, color, and size. It's completely independent and can
/// be used anywhere loading states need to be displayed.
///
/// Example usage:
/// ```dart
/// LoadingOverlay(
///   isLoading: true,
///   loadingText: 'Loading players...',
///   child: PlayerList(),
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  /// Creates a loading overlay widget
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
    this.animationSize = 50.0,
    this.animationColor,
  });

  /// Whether to show the loading overlay
  final bool isLoading;

  /// Child widget to display when not loading
  final Widget child;

  /// Optional text to display below the loading animation
  final String? loadingText;

  /// Size of the loading animation
  final double animationSize;

  /// Color of the loading animation (defaults to AppColors.textEnabledColor)
  final Color? animationColor;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.waveDots(
            color: animationColor ?? AppColors.textEnabledColor,
            size: animationSize,
          ),
          if (loadingText != null) ...[
            const SizedBox(height: 16),
            Text(
              loadingText!,
              style: TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
