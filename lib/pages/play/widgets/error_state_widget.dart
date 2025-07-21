import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable error state widget that displays error messages with retry functionality
///
/// Features:
/// - Consistent error UI across the app
/// - Optional retry button with callback
/// - Responsive design with proper spacing
/// - Accessibility support
class ErrorStateWidget extends StatelessWidget {
  /// Creates an error state widget
  ///
  /// [title] - The main error title to display
  /// [message] - Optional detailed error message
  /// [onRetry] - Callback function for retry button (if null, button is hidden)
  /// [retryButtonText] - Text for the retry button (default: 'Retry')
  const ErrorStateWidget({
    required this.title,
    this.message,
    this.onRetry,
    this.retryButtonText = 'Retry',
    super.key,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryButtonText;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.12;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: iconSize,
              color: AppColors.errorColor,
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              title,
              style: TextStyle(
                color: AppColors.errorColor,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: screenWidth * 0.02),
              Text(
                message!,
                style: TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: screenWidth * 0.035,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: screenWidth * 0.04),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textEnabledColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenWidth * 0.03,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(retryButtonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
