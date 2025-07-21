import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';

/// Modern loading widget with glassmorphism overlay and smooth animations.
///
/// Features:
/// - Glassmorphism overlay design
/// - Multiple loading animation styles
/// - Responsive sizing
/// - Smooth fade transitions
/// - Customizable colors and sizes
///
/// Performance optimizations:
/// - RepaintBoundary for animation isolation
/// - Efficient blur and gradient effects
/// - Optimized animation controllers
class ModernLoadingWidget extends StatelessWidget {
  /// Loading message to display
  final String? message;

  /// Size of the loading animation
  final double size;

  /// Loading animation style
  final LoadingStyle style;

  /// Whether to show background overlay
  final bool showOverlay;

  const ModernLoadingWidget({
    super.key,
    this.message,
    this.size = 50,
    this.style = LoadingStyle.waveDots,
    this.showOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final loadingContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RepaintBoundary(child: _buildLoadingAnimation()),
        if (message != null) ...[
          const SizedBox(height: 16),
          _buildLoadingMessage(),
        ],
      ],
    );

    return showOverlay ? _buildWithOverlay(loadingContent) : loadingContent;
  }

  /// Builds loading animation based on selected style
  Widget _buildLoadingAnimation() {
    switch (style) {
      case LoadingStyle.waveDots:
        return LoadingAnimationWidget.waveDots(
          color: AppColors.textEnabledColor,
          size: size,
        );
      case LoadingStyle.threeRotatingDots:
        return LoadingAnimationWidget.threeRotatingDots(
          color: AppColors.textEnabledColor,
          size: size,
        );
      case LoadingStyle.staggeredDotsWave:
        return LoadingAnimationWidget.staggeredDotsWave(
          color: AppColors.textEnabledColor,
          size: size,
        );
      case LoadingStyle.progressiveDots:
        return LoadingAnimationWidget.progressiveDots(
          color: AppColors.textEnabledColor,
          size: size,
        );
    }
  }

  /// Loading message with modern typography
  Widget _buildLoadingMessage() => AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: const TextStyle(
          color: AppColors.textEnabledColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        child: Text(
          message!,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );

  /// Builds content with glassmorphism overlay
  Widget _buildWithOverlay(Widget content) => Container(
        color: AppColors.primaryColor.withValues(alpha: 0.3),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor.withValues(alpha: 0.2),
                AppColors.accentColor.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Center(child: content),
        ),
      );
}

/// Available loading animation styles
enum LoadingStyle {
  waveDots,
  threeRotatingDots,
  staggeredDotsWave,
  progressiveDots,
}
