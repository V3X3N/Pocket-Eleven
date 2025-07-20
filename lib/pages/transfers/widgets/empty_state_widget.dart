import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable empty state widget that displays when no data is available.
///
/// Features:
/// - Customizable icon, title, and message
/// - Responsive design for different screen sizes
/// - Modern opacity-based styling
/// - Consistent spacing and typography
class EmptyStateWidget extends StatelessWidget {
  /// Creates an empty state widget.
  ///
  /// [icon] - The icon to display (required)
  /// [title] - The main title text (required)
  /// [message] - The subtitle message (required)
  /// [iconSize] - Size of the icon (default: 64.0)
  /// [height] - Height of the container (default: 400.0)
  /// [padding] - Padding inside the container (default: EdgeInsets.all(32))
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconSize = 64.0,
    this.height = 400.0,
    this.padding = const EdgeInsets.all(32),
  });

  /// The icon to display at the top
  final IconData icon;

  /// The main title text
  final String title;

  /// The subtitle message
  final String message;

  /// Size of the icon
  final double iconSize;

  /// Height of the container
  final double height;

  /// Padding inside the container
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: AppColors.textEnabledColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textEnabledColor.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textEnabledColor.withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
