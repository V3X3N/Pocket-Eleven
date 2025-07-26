import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String? cancelText;
  final String? confirmText;
  final Color? cancelColor;
  final Color? confirmColor;
  final IconData? icon;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
    this.cancelText,
    this.confirmText,
    this.cancelColor,
    this.confirmColor,
    this.icon,
  });

  // Cache computed values to avoid recalculation
  static const double _borderRadius = 24.0;
  static const double _buttonSpacing = 12.0;
  static const double _contentSpacing = 20.0;
  static const double _iconSize = 32.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 400;

    return RepaintBoundary(
      child: Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius)),
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isSmall ? size.width * 0.9 : 400,
            maxHeight: size.height * 0.5,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondaryColor, AppColors.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(_borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(isSmall ? 20 : 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (confirmColor ?? AppColors.blueColor)
                        .withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon!,
                    size: _iconSize,
                    color: confirmColor ?? AppColors.blueColor,
                  ),
                ),
                const SizedBox(height: _contentSpacing),
              ],
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: isSmall ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  color: AppColors.coffeeText,
                  fontSize: isSmall ? 14 : 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _buildActionButtons(context, isSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isSmall) {
    return RepaintBoundary(
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => _handleCancel(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                cancelText ?? 'Cancel',
                style: TextStyle(
                  color: cancelColor ?? AppColors.errorColor,
                  fontSize: isSmall ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: _buttonSpacing),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleConfirm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? AppColors.blueColor,
                foregroundColor: AppColors.textEnabledColor,
                padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Text(
                confirmText ?? 'Confirm',
                style: TextStyle(
                  fontSize: isSmall ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCancel(BuildContext context) {
    Navigator.of(context).pop(false);
    onCancel();
  }

  void _handleConfirm(BuildContext context) {
    Navigator.of(context).pop(true);
    onConfirm();
  }
}

// Extension method for easy usage
extension DialogExtensions on BuildContext {
  Future<bool?> showCustomConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    String? cancelText,
    String? confirmText,
    Color? cancelColor,
    Color? confirmColor,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: this,
      barrierDismissible: false,
      builder: (context) => CustomConfirmDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
        onCancel: onCancel,
        cancelText: cancelText,
        confirmText: confirmText,
        cancelColor: cancelColor,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
  }
}
