import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// **Modern action button with smooth animations and loading states**
///
/// Features:
/// - Glass-morphic design with subtle shadows
/// - Smooth scale and fade animations
/// - Responsive sizing and typography
/// - Optimized loading transitions
class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ValueNotifier<bool>? isLoading;
  final double? width;
  final double height;
  final double fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const ActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading,
    this.width,
    this.height = 56,
    this.fontSize = 16,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: isLoading != null
            ? ValueListenableBuilder<bool>(
                valueListenable: isLoading!,
                builder: (_, loading, __) =>
                    _buildButton(context, theme, isEnabled, loading),
              )
            : _buildButton(context, theme, isEnabled, false),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, ThemeData theme, bool isEnabled, bool isLoading) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveFontSize = fontSize * (screenWidth > 400 ? 1.0 : 0.9);
    final bgColor = backgroundColor ??
        (isEnabled ? AppColors.textEnabledColor : AppColors.inputBorder);
    final fgColor =
        textColor ?? (isEnabled ? AppColors.primaryColor : AppColors.inputIcon);

    return AnimatedScale(
      scale: isEnabled && !isLoading ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 150),
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isEnabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      bgColor,
                      bgColor.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            color: !isEnabled ? bgColor : null,
            boxShadow: isEnabled && !isLoading
                ? [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(18),
              splashColor: fgColor.withValues(alpha: 0.1),
              highlightColor: fgColor.withValues(alpha: 0.05),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth > 400 ? 24 : 16,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(fgColor),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon != null) ...[
                              Icon(
                                icon,
                                size: responsiveFontSize + 2,
                                color: fgColor,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: responsiveFontSize,
                                fontWeight: FontWeight.w600,
                                color: fgColor,
                                letterSpacing: 0.3,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
