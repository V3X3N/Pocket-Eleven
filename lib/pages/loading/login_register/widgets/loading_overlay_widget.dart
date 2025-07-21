// File: widgets/common/loading_overlay.dart
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// **Modern loading overlay with animated spinner and message**
///
/// Creates a full-screen loading overlay with:
/// - Smooth fade-in animation
/// - Custom loading message
/// - Modern spinner design
/// - Backdrop blur effect
/// - Responsive sizing
///
/// **Parameters:**
/// - [message] - Loading message text (default: 'Loading...')
/// - [backgroundColor] - Overlay background color (default: black with 70% opacity)
/// - [spinnerColor] - Spinner color (default: AppColors.textEnabledColor)
/// - [textColor] - Message text color (default: AppColors.textEnabledColor)
/// - [spinnerSize] - Spinner size (default: 48)
/// - [fontSize] - Message font size (default: 18)
/// - [spacing] - Space between spinner and text (default: 24)
///
/// **Usage:**
/// ```dart
/// LoadingOverlay(
///   message: 'Creating your account...',
/// )
/// ```
class LoadingOverlay extends StatefulWidget {
  /// Loading message text
  final String message;

  /// Overlay background color
  final Color backgroundColor;

  /// Spinner color
  final Color spinnerColor;

  /// Message text color
  final Color textColor;

  /// Spinner size
  final double spinnerSize;

  /// Message font size
  final double fontSize;

  /// Space between spinner and text
  final double spacing;

  const LoadingOverlay({
    super.key,
    this.message = 'Loading...',
    this.backgroundColor = const Color(0xB3000000), // Black with 70% opacity
    this.spinnerColor = AppColors.textEnabledColor,
    this.textColor = AppColors.textEnabledColor,
    this.spinnerSize = 48,
    this.fontSize = 18,
    this.spacing = 24,
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = _getResponsiveFontSize(context);
    final responsiveSpinnerSize = _getResponsiveSpinnerSize(context);
    final responsiveSpacing = _getResponsiveSpacing(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: widget.backgroundColor,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSpinner(responsiveSpinnerSize),
                  SizedBox(height: responsiveSpacing),
                  _buildMessage(responsiveFontSize),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpinner(double size) {
    return RepaintBoundary(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(widget.spinnerColor),
          strokeWidth: 3.5,
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }

  Widget _buildMessage(double fontSize) {
    return RepaintBoundary(
      child: Text(
        widget.message,
        style: TextStyle(
          color: widget.textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  double _getResponsiveFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return widget.fontSize;
    if (screenWidth > 400) return widget.fontSize * 0.9;
    return widget.fontSize * 0.85;
  }

  double _getResponsiveSpinnerSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return widget.spinnerSize;
    if (screenWidth > 400) return widget.spinnerSize * 0.9;
    return widget.spinnerSize * 0.8;
  }

  double _getResponsiveSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) return widget.spacing;
    if (screenWidth > 400) return widget.spacing * 0.9;
    return widget.spacing * 0.8;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
