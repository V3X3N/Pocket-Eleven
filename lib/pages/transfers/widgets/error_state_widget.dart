import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable error state widget that displays error information
/// with retry functionality and modern design.
///
/// Features:
/// - Clean error display with icon
/// - Customizable error message and title
/// - Retry button with callback
/// - Responsive padding and spacing
/// - Modern card design with shadows
class ErrorStateWidget extends StatelessWidget {
  /// Creates an error state widget.
  ///
  /// [title] - The error title to display (required)
  /// [message] - The error message to display (required)
  /// [onRetry] - Callback function when retry button is pressed (required)
  /// [retryText] - Text for the retry button (default: 'Retry')
  /// [margin] - Margin around the error container (default: EdgeInsets.all(16))
  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.retryText = 'Retry',
    this.margin = const EdgeInsets.all(16),
  });

  /// The title of the error message
  final String title;

  /// The detailed error message
  final String message;

  /// Callback function when retry button is pressed
  final VoidCallback onRetry;

  /// Text displayed on the retry button
  final String retryText;

  /// Margin around the error container
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade300,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(retryText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.hoverColor,
              foregroundColor: AppColors.textEnabledColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
