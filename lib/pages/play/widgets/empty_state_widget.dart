import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable empty state widget for displaying when no data is available
///
/// Features:
/// - Customizable icon and messages
/// - Responsive design
/// - Consistent styling across the app
/// - Optional action button
class EmptyStateWidget extends StatelessWidget {
  /// Creates an empty state widget
  ///
  /// [icon] - The icon to display (default: Icons.sports_soccer)
  /// [title] - The main message to display
  /// [subtitle] - Optional secondary message
  /// [actionText] - Optional action button text
  /// [onAction] - Callback for action button
  const EmptyStateWidget({
    this.icon = Icons.sports_soccer,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

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
              icon,
              size: iconSize,
              color: AppColors.textEnabledColor.withValues(alpha: 0.6),
            ),
            SizedBox(height: screenWidth * 0.04),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: screenWidth * 0.02),
              Text(
                subtitle!,
                style: TextStyle(
                  color: AppColors.textEnabledColor.withValues(alpha: 0.7),
                  fontSize: screenWidth * 0.035,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              SizedBox(height: screenWidth * 0.04),
              ElevatedButton(
                onPressed: onAction,
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
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
