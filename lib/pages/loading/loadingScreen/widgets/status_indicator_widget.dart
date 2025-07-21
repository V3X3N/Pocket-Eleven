import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/loading/loadingScreen/widgets/error_indicator_widget.dart';

/// A reusable status indicator widget that displays loading, error, or empty states.
///
/// This widget efficiently manages different loading states with:
/// - Smooth AnimatedSwitcher transitions between states
/// - Optimized widget rebuilding using ValueKey
/// - 60fps performance with minimal widget tree changes
/// - Defensive null checking and error handling
///
/// Usage:
/// ```dart
/// StatusIndicator(
///   isLoading: controller.isLoading,
///   errorMessage: controller.errorMessage,
///   onRetry: controller.retry,
/// )
/// ```
class StatusIndicator extends StatelessWidget {
  /// Whether the indicator should show loading state
  final bool isLoading;

  /// Error message to display, null if no error
  final String? errorMessage;

  /// Callback function when retry button is pressed
  final VoidCallback? onRetry;

  /// Custom loading widget, if null uses default animation
  final Widget? loadingWidget;

  /// Custom loading color, if null uses theme color
  final Color? loadingColor;

  /// Custom loading size
  final double loadingSize;

  /// Custom animation duration for state transitions
  final Duration animationDuration;

  /// Creates a status indicator widget.
  ///
  /// [isLoading] determines if loading animation is shown.
  /// [errorMessage] if provided, shows error state instead of loading.
  /// [onRetry] callback for retry button in error state.
  /// [loadingWidget] custom loading animation (optional).
  /// [loadingColor] custom color for loading animation.
  /// [loadingSize] size of the loading animation.
  /// [animationDuration] transition duration between states.
  const StatusIndicator({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
    this.loadingWidget,
    this.loadingColor,
    this.loadingSize = 45.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: animationDuration,
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _buildCurrentState(),
    );
  }

  /// Builds the appropriate widget based on current state
  Widget _buildCurrentState() {
    // Error state has highest priority
    if (errorMessage != null) {
      return ErrorIndicator(
        key: const ValueKey('error'),
        message: errorMessage!,
        onRetry: onRetry,
      );
    }

    // Loading state
    if (isLoading) {
      return _buildLoadingWidget();
    }

    // Empty/success state
    return const SizedBox.shrink(
      key: ValueKey('empty'),
    );
  }

  /// Builds the loading animation widget
  Widget _buildLoadingWidget() {
    final effectiveColor = loadingColor ?? AppColors.textEnabledColor;

    return loadingWidget ??
        LoadingAnimationWidget.threeArchedCircle(
          key: const ValueKey('loading'),
          color: effectiveColor,
          size: loadingSize,
        );
  }
}
