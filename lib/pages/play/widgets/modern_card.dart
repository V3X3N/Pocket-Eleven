import 'package:flutter/material.dart';

/// A modern glassmorphic card widget with gradient background and shadow effects.
///
/// This widget provides a consistent card design across the app with:
/// - Gradient background with customizable opacity
/// - Rounded corners and subtle shadows
/// - Border with transparency
/// - Optional fixed height
///
/// Usage:
/// ```dart
/// ModernCard(
///   height: 200,
///   child: YourContentWidget(),
/// )
/// ```
class ModernCard extends StatelessWidget {
  /// Creates a modern card widget.
  ///
  /// [child] - The widget to display inside the card
  /// [height] - Optional fixed height for the card
  /// [margin] - Card margin, defaults to 16px all around
  /// [padding] - Card padding, defaults to 20px all around
  const ModernCard({
    super.key,
    required this.child,
    this.height,
    this.margin = const EdgeInsets.all(16),
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      padding: padding,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xE6212332), // AppColors.hoverColor with 90% opacity
            Color(0xB3212332), // AppColors.hoverColor with 70% opacity
            Color(0xCC212332), // AppColors.hoverColor with 80% opacity
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A1A1A2E), // AppColors.primaryColor with 10% opacity
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color:
                Color(0x0DF8F5FA), // AppColors.textEnabledColor with 5% opacity
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
        border: Border.fromBorderSide(
          BorderSide(
            color: Color(
                0x1AF8F5FA), // AppColors.textEnabledColor with 10% opacity
            width: 1,
          ),
        ),
      ),
      child: child,
    );
  }
}
