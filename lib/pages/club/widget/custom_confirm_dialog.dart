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
  });

  // Cache computed values to avoid recalculation
  static const double _borderRadius = 10.0;
  static const double _borderWidth = 1.0;
  static const double _paddingRatio = 0.04;
  static const double _maxWidthRatio = 0.8;
  static const double _buttonSpacing = 8.0;
  static const double _contentSpacing = 20.0;
  static const EdgeInsets _titlePadding = EdgeInsets.all(16.0);
  static const EdgeInsets _messagePadding =
      EdgeInsets.symmetric(horizontal: 16.0);

  // Pre-computed text styles to avoid recreation
  static const TextStyle _titleStyle = TextStyle(
    color: AppColors.textEnabledColor,
    fontWeight: FontWeight.w600,
    fontSize: 18.0,
  );

  static const TextStyle _messageStyle = TextStyle(
    color: AppColors.textEnabledColor,
    fontSize: 16.0,
  );

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerPadding = screenWidth * _paddingRatio;
    final double maxWidth = screenWidth * _maxWidthRatio;

    return RepaintBoundary(
      child: Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: EdgeInsets.all(containerPadding),
            decoration: const BoxDecoration(
              color: AppColors.hoverColor,
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.borderColor, width: _borderWidth),
              ),
              borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: _titlePadding,
                  child: Text(
                    title,
                    style: _titleStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: _messagePadding,
                  child: Text(
                    message,
                    style: _messageStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: _contentSpacing),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _CancelButton(
            onPressed: () => _handleCancel(context),
            text: cancelText ?? 'Cancel',
            color: cancelColor ?? Colors.red,
          ),
          const SizedBox(width: _buttonSpacing),
          _ConfirmButton(
            onPressed: () => _handleConfirm(context),
            text: confirmText ?? 'Upgrade',
            color: confirmColor ?? AppColors.blueColor,
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

// Separate button widgets to optimize rebuilding
class _CancelButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;

  const _CancelButton({
    required this.onPressed,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        minimumSize: const Size(64, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;

  const _ConfirmButton({
    required this.onPressed,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        minimumSize: const Size(64, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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
      ),
    );
  }
}
