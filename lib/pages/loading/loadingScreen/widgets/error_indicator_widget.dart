import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable error indicator widget with modern design and retry functionality.
///
/// This widget provides a consistent error display with:
/// - Modern glassmorphism design matching app theme
/// - Customizable error messages and retry actions
/// - Haptic feedback for better user experience
/// - Responsive design for different screen sizes
/// - Optimized rendering for smooth 60fps performance
///
/// Usage:
/// ```dart
/// ErrorIndicator(
///   message: 'Network connection failed',
///   onRetry: () => controller.retry(),
/// )
/// ```
class ErrorIndicator extends StatelessWidget {
  /// The error message to display to the user
  final String message;

  /// Callback function when retry button is pressed
  final VoidCallback? onRetry;

  /// Custom title for the error (defaults to 'Connection Error')
  final String? errorTitle;

  /// Custom icon for the error display
  final IconData? errorIcon;

  /// Custom retry button text (defaults to 'Retry')
  final String? retryText;

  /// Custom error color theme
  final Color? errorColor;

  /// Creates an error indicator widget.
  ///
  /// [message] is the error message shown to user.
  /// [onRetry] callback for retry button, if null button is hidden.
  /// [errorTitle] custom title text for the error.
  /// [errorIcon] custom icon, defaults to error_outline.
  /// [retryText] custom text for retry button.
  /// [errorColor] custom color for error elements.
  const ErrorIndicator({
    super.key,
    required this.message,
    this.onRetry,
    this.errorTitle,
    this.errorIcon,
    this.retryText,
    this.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final effectiveErrorColor = errorColor ?? Colors.red.shade300;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildErrorIcon(effectiveErrorColor),
        SizedBox(height: isSmallScreen ? 6 : 8),
        _buildErrorTitle(isSmallScreen),
        if (onRetry != null) ...[
          SizedBox(height: isSmallScreen ? 10 : 12),
          _buildRetryButton(isSmallScreen),
        ],
      ],
    );
  }

  /// Builds the error icon with glassmorphism container
  Widget _buildErrorIcon(Color effectiveErrorColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: (errorColor ?? Colors.red).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (errorColor ?? Colors.red).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        errorIcon ?? Icons.error_outline,
        color: effectiveErrorColor,
        size: 24,
      ),
    );
  }

  /// Builds the error title text
  Widget _buildErrorTitle(bool isSmallScreen) {
    return Text(
      errorTitle ?? 'Connection Error',
      style: TextStyle(
        color: AppColors.textEnabledColor,
        fontSize: isSmallScreen ? 11 : 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Builds the retry button with haptic feedback
  Widget _buildRetryButton(bool isSmallScreen) {
    return TextButton.icon(
      onPressed: _handleRetry,
      icon: Icon(
        Icons.refresh,
        size: isSmallScreen ? 16 : 18,
      ),
      label: Text(
        retryText ?? 'Retry',
        style: TextStyle(
          fontSize: isSmallScreen ? 11 : 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textEnabledColor,
        backgroundColor: Colors.white.withValues(alpha: 0.15),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 6 : 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    );
  }

  /// Handles retry button press with haptic feedback
  void _handleRetry() {
    HapticFeedback.lightImpact();
    onRetry?.call();
  }
}
