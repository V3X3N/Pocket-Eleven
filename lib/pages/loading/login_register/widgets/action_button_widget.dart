// File: widgets/form/action_button.dart
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// **Modern action button with loading state and animations**
///
/// Features:
/// - Smooth loading transitions
/// - Disabled state handling
/// - Responsive sizing
/// - Modern elevation and shadows
/// - Customizable styling
///
/// **Parameters:**
/// - [text] - Button text (required)
/// - [onPressed] - Callback function (null disables button)
/// - [isLoading] - ValueNotifier for loading state (optional)
/// - [width] - Button width (default: fit content)
/// - [height] - Button height (default: 56)
/// - [fontSize] - Text font size (default: 18)
/// - [borderRadius] - Border radius (default: 16)
/// - [backgroundColor] - Custom background color (optional)
/// - [textColor] - Custom text color (optional)
/// - [icon] - Optional leading icon
///
/// **Usage:**
/// ```dart
/// ActionButton(
///   text: 'Submit',
///   onPressed: handleSubmit,
///   isLoading: loadingNotifier,
///   width: double.infinity,
/// )
/// ```
class ActionButton extends StatelessWidget {
  /// Button text
  final String text;

  /// Callback function when pressed
  final VoidCallback? onPressed;

  /// Loading state notifier
  final ValueNotifier<bool>? isLoading;

  /// Button width
  final double? width;

  /// Button height
  final double height;

  /// Text font size
  final double fontSize;

  /// Border radius
  final double borderRadius;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom text color
  final Color? textColor;

  /// Optional leading icon
  final IconData? icon;

  const ActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading,
    this.width,
    this.height = 56,
    this.fontSize = 18,
    this.borderRadius = 16,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: isLoading != null
            ? ValueListenableBuilder<bool>(
                valueListenable: isLoading!,
                builder: (context, loading, _) => _buildButton(
                  context,
                  isEnabled,
                  loading,
                ),
              )
            : _buildButton(context, isEnabled, false),
      ),
    );
  }

  Widget _buildButton(BuildContext context, bool isEnabled, bool isLoading) {
    final effectiveBackgroundColor = _getBackgroundColor(isEnabled);
    final effectiveTextColor = _getTextColor(isEnabled);
    final responsiveFontSize = _getResponsiveFontSize(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          elevation: isEnabled && !isLoading ? 8 : 0,
          shadowColor: effectiveBackgroundColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(context),
            vertical: 0,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isLoading
              ? _buildLoadingContent()
              : _buildButtonContent(responsiveFontSize, effectiveTextColor),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          textColor ?? AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildButtonContent(
      double responsiveFontSize, Color effectiveTextColor) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: responsiveFontSize + 2,
            color: effectiveTextColor,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: responsiveFontSize,
              fontWeight: FontWeight.bold,
              color: effectiveTextColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: responsiveFontSize,
        fontWeight: FontWeight.bold,
        color: effectiveTextColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Color _getBackgroundColor(bool isEnabled) {
    if (backgroundColor != null) return backgroundColor!;
    return isEnabled ? AppColors.textEnabledColor : AppColors.inputBorder;
  }

  Color _getTextColor(bool isEnabled) {
    if (textColor != null) return textColor!;
    return isEnabled ? AppColors.primaryColor : AppColors.inputIcon;
  }

  double _getResponsiveFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return fontSize;
    if (screenWidth > 400) return fontSize * 0.9;
    return fontSize * 0.85;
  }

  double _getHorizontalPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return 32;
    if (screenWidth > 400) return 24;
    return 16;
  }
}
