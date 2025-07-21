import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// Modern error display widget with glassmorphism design and retry functionality.
///
/// Features:
/// - Glassmorphism visual effects
/// - Animated error icon
/// - Customizable error messages
/// - Retry button with smooth interactions
/// - Responsive typography and spacing
///
/// Performance optimizations:
/// - Const constructors where possible
/// - RepaintBoundary for icon animations
/// - Efficient gradient implementations
class ModernErrorWidget extends StatefulWidget {
  /// Error message to display
  final String message;

  /// Retry button text
  final String retryText;

  /// Callback when retry button is pressed
  final VoidCallback? onRetry;

  /// Error icon to display
  final IconData icon;

  /// Whether to show retry button
  final bool showRetry;

  const ModernErrorWidget({
    super.key,
    required this.message,
    this.retryText = 'Retry',
    this.onRetry,
    this.icon = Icons.error_outline,
    this.showRetry = true,
  });

  @override
  State<ModernErrorWidget> createState() => _ModernErrorWidgetState();
}

class _ModernErrorWidgetState extends State<ModernErrorWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(16),
        decoration: _buildErrorContainerDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildErrorIcon(),
            const SizedBox(height: 24),
            _buildErrorMessage(),
            if (widget.showRetry && widget.onRetry != null) ...[
              const SizedBox(height: 32),
              _buildRetryButton(),
            ],
          ],
        ),
      ),
    );
  }

  /// Error container decoration with glassmorphism
  BoxDecoration _buildErrorContainerDecoration() => BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.hoverColor.withValues(alpha: 0.8),
            AppColors.accentColor.withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: AppColors.errorColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.errorColor.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      );

  /// Animated error icon
  Widget _buildErrorIcon() => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) => Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.errorColor.withValues(alpha: 0.2),
                    AppColors.errorColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Icon(
                widget.icon,
                size: 48,
                color: AppColors.errorColor,
              ),
            ),
          ),
        ),
      );

  /// Error message with modern typography
  Widget _buildErrorMessage() => Text(
        widget.message,
        style: const TextStyle(
          color: AppColors.textEnabledColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );

  /// Retry button with modern styling
  Widget _buildRetryButton() => ElevatedButton(
        onPressed: widget.onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueColor,
          foregroundColor: AppColors.textEnabledColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: AppColors.blueColor.withValues(alpha: 0.4),
        ),
        child: Text(
          widget.retryText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );
}
