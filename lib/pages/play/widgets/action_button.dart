import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A modern action button with gradient background and haptic feedback.
///
/// This widget provides:
/// - Gradient background with customizable colors
/// - Rounded corners with shadow
/// - Haptic feedback on tap
/// - Icon and text support
/// - Responsive text sizing
///
/// Usage:
/// ```dart
/// ActionButton(
///   text: 'Simulate Match',
///   icon: Icons.play_arrow_rounded,
///   onPressed: () => handleAction(),
///   screenWidth: MediaQuery.of(context).size.width,
/// )
/// ```
class ActionButton extends StatelessWidget {
  /// Creates an action button.
  ///
  /// [text] - Button text
  /// [onPressed] - Callback when button is pressed
  /// [screenWidth] - Screen width for responsive scaling
  /// [icon] - Optional icon to display
  /// [gradientColors] - Custom gradient colors (defaults to green gradient)
  /// [shadowColor] - Custom shadow color
  const ActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.screenWidth,
    this.icon,
    this.gradientColors = const [
      Color(0xCC028A0F), // AppColors.green with 80% opacity
      AppColors.green,
    ],
    this.shadowColor =
        const Color(0x66028A0F), // AppColors.green with 40% opacity
  });

  final String text;
  final VoidCallback onPressed;
  final double screenWidth;
  final IconData? icon;
  final List<Color> gradientColors;
  final Color shadowColor;

  static final _scaleCache = <String, double>{};

  double _getScaledFontSize(double size) => _scaleCache.putIfAbsent(
      '${screenWidth}_font_$size',
      () => size * (screenWidth / 375.0).clamp(0.8, 2.0));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 24,
                    color: AppColors.textEnabledColor,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: _getScaledFontSize(16),
                    color: AppColors.textEnabledColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
