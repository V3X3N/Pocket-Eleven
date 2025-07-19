import 'package:flutter/material.dart';

/// An empty state widget for displaying when no content is available.
///
/// This widget provides:
/// - Icon with responsive sizing
/// - Message text with proper styling
/// - Centered layout
/// - Consistent theming
///
/// Usage:
/// ```dart
/// EmptyState(
///   icon: Icons.sports_soccer_rounded,
///   message: 'No upcoming matches',
///   screenWidth: MediaQuery.of(context).size.width,
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Creates an empty state widget.
  ///
  /// [icon] - Icon to display
  /// [message] - Message text to display
  /// [screenWidth] - Screen width for responsive scaling
  /// [iconSize] - Base size for the icon
  /// [fontSize] - Base font size for the message
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    required this.screenWidth,
    this.iconSize = 60,
    this.fontSize = 18,
  });

  final IconData icon;
  final String message;
  final double screenWidth;
  final double iconSize;
  final double fontSize;

  static final _scaleCache = <String, double>{};

  double _getScaledSize(double size, String type) => _scaleCache.putIfAbsent(
      '${screenWidth}_${type}_$size',
      () => size * (screenWidth / 375.0).clamp(0.8, 2.0));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: _getScaledSize(iconSize, 'icon'),
            color: const Color(
                0x99F8F5FA), // AppColors.textEnabledColor with 60% opacity
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: _getScaledSize(fontSize, 'font'),
              color: const Color(
                  0xCCF8F5FA), // AppColors.textEnabledColor with 80% opacity
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
