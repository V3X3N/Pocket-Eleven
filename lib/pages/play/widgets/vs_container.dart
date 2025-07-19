import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A versus (VS) container widget for match displays.
///
/// This widget provides:
/// - Gradient background with rounded corners
/// - Responsive text sizing
/// - Border with transparency
/// - Consistent styling across match displays
///
/// Usage:
/// ```dart
/// VSContainer(
///   screenWidth: MediaQuery.of(context).size.width,
///   text: 'VS',
/// )
/// ```
class VSContainer extends StatelessWidget {
  /// Creates a VS container widget.
  ///
  /// [screenWidth] - Screen width for responsive scaling
  /// [text] - Text to display (defaults to 'VS')
  const VSContainer({
    super.key,
    required this.screenWidth,
    this.text = 'VS',
  });

  final double screenWidth;
  final String text;

  static final _scaleCache = <String, double>{};

  double _getScaledFontSize(double size) => _scaleCache.putIfAbsent(
      '${screenWidth}_font_$size',
      () => size * (screenWidth / 375.0).clamp(0.8, 2.0));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x4D717483), // AppColors.borderColor with 30% opacity
            Color(0x1A717483), // AppColors.borderColor with 10% opacity
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.fromBorderSide(
          BorderSide(
            color: Color(
                0x1AF8F5FA), // AppColors.textEnabledColor with 10% opacity
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _getScaledFontSize(24),
          fontWeight: FontWeight.bold,
          color: AppColors.textEnabledColor,
        ),
      ),
    );
  }
}
