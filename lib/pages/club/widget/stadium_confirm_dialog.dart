import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class StadiumConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const StadiumConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
  });

  // Cache commonly used values to avoid repeated calculations
  static const double _maxWidthRatio = 0.8;
  static const double _paddingRatio = 0.04;
  static const double _borderRadius = 10.0;
  static const EdgeInsets _titlePadding = EdgeInsets.all(16.0);
  static const EdgeInsets _messagePadding =
      EdgeInsets.symmetric(horizontal: 16.0);
  static const SizedBox _verticalSpacer = SizedBox(height: 20);
  static const SizedBox _horizontalSpacer = SizedBox(width: 8);

  // Pre-computed text styles to avoid recreation
  static const TextStyle _textStyle =
      TextStyle(color: AppColors.textEnabledColor);
  static const TextStyle _cancelStyle = TextStyle(color: Colors.red);
  static const TextStyle _confirmStyle = TextStyle(color: AppColors.blueColor);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      child: RepaintBoundary(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenWidth * _maxWidthRatio),
          child: Material(
            color: AppColors.hoverColor,
            shape: RoundedRectangleBorder(
              borderRadius:
                  const BorderRadius.all(Radius.circular(_borderRadius)),
              side: const BorderSide(color: AppColors.borderColor, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * _paddingRatio),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: _titlePadding,
                    child: Text(title, style: _textStyle),
                  ),
                  Padding(
                    padding: _messagePadding,
                    child: Text(message, style: _textStyle),
                  ),
                  _verticalSpacer,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _handleCancel,
                        child: const Text('Cancel', style: _cancelStyle),
                      ),
                      _horizontalSpacer,
                      TextButton(
                        onPressed: _handleConfirm,
                        child: const Text('Confirm', style: _confirmStyle),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleCancel() {
    onCancel();
  }

  void _handleConfirm() {
    onConfirm();
  }
}
