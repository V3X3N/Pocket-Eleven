// File: widgets/common/navigation_prompt.dart
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// **Interactive navigation prompt with modern styling**
///
/// Creates a tappable prompt with icon and text for navigation between screens.
/// Features hover effects and responsive design.
///
/// **Parameters:**
/// - [icon] - Leading icon (required)
/// - [text] - Prompt text (required)
/// - [onTap] - Callback when tapped (required)
/// - [backgroundColor] - Background color (optional)
/// - [textColor] - Text color (default: AppColors.textEnabledColor)
/// - [iconColor] - Icon color (default: AppColors.textEnabledColor)
/// - [borderColor] - Border color (default: AppColors.inputBorder)
/// - [borderRadius] - Border radius (default: 25)
/// - [padding] - Internal padding (default: 16v, 24h)
/// - [fontSize] - Text font size (default: 16)
/// - [iconSize] - Icon size (default: 18)
///
/// **Usage:**
/// ```dart
/// NavigationPrompt(
///   icon: Icons.login,
///   text: 'Already have an account? Sign in',
///   onTap: () => Navigator.push(...),
/// )
/// ```
class NavigationPrompt extends StatefulWidget {
  /// Leading icon
  final IconData icon;

  /// Prompt text
  final String text;

  /// Callback when tapped
  final VoidCallback onTap;

  /// Background color
  final Color? backgroundColor;

  /// Text color
  final Color textColor;

  /// Icon color
  final Color iconColor;

  /// Border color
  final Color borderColor;

  /// Border radius
  final double borderRadius;

  /// Internal padding
  final EdgeInsets padding;

  /// Text font size
  final double fontSize;

  /// Icon size
  final double iconSize;

  const NavigationPrompt({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor = AppColors.textEnabledColor,
    this.iconColor = AppColors.textEnabledColor,
    this.borderColor = AppColors.inputBorder,
    this.borderRadius = 25,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    this.fontSize = 16,
    this.iconSize = 18,
  });

  @override
  State<NavigationPrompt> createState() => _NavigationPromptState();
}

class _NavigationPromptState extends State<NavigationPrompt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<Color?> _colorAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _colorAnimation = ColorTween(
      begin: widget.backgroundColor ?? AppColors.backgroundOverlay,
      end: widget.borderColor.withValues(alpha: 0.1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = _getResponsiveFontSize(context);
    final responsiveIconSize = _getResponsiveIconSize(context);
    final responsivePadding = _getResponsivePadding(context);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: responsivePadding,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isPressed
                      ? widget.borderColor.withValues(alpha: 0.8)
                      : widget.borderColor,
                  width: _isPressed ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                color: _colorAnimation.value,
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: widget.borderColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.iconColor,
                    size: responsiveIconSize,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: responsiveFontSize,
                        color: widget.textColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _resetPressState();
  }

  void _onTapCancel() {
    _resetPressState();
  }

  void _resetPressState() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  double _getResponsiveFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return widget.fontSize;
    if (screenWidth > 400) return widget.fontSize * 0.9;
    return widget.fontSize * 0.85;
  }

  double _getResponsiveIconSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return widget.iconSize;
    if (screenWidth > 400) return widget.iconSize * 0.9;
    return widget.iconSize * 0.85;
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return widget.padding;
    if (screenWidth > 400) {
      return EdgeInsets.symmetric(
        vertical: widget.padding.vertical * 0.9,
        horizontal: widget.padding.horizontal * 0.9,
      );
    }
    return EdgeInsets.symmetric(
      vertical: widget.padding.vertical * 0.8,
      horizontal: widget.padding.horizontal * 0.8,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
