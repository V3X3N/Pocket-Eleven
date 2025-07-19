// File: widgets/form/optimized_text_field.dart
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// **High-performance text field with real-time validation**
///
/// Features:
/// - Real-time visual feedback with color-coded borders
/// - Animated validation icons
/// - Optimized rebuilds with ValueNotifier
/// - Modern glassmorphism design
/// - Responsive sizing for all devices
///
/// **Parameters:**
/// - [label] - Field label text (required)
/// - [icon] - Prefix icon (required)
/// - [controller] - Text editing controller (required)
/// - [validator] - Validation function (required)
/// - [isPassword] - Whether field is password type (default: false)
/// - [keyboardType] - Keyboard input type (default: text)
/// - [borderRadius] - Border radius (default: 16)
/// - [contentPadding] - Internal padding (default: 20 all)
///
/// **Usage:**
/// ```dart
/// OptimizedTextField(
///   label: 'Email',
///   icon: Icons.email,
///   controller: emailController,
///   validator: (value) => value?.isEmpty == true ? 'Required' : null,
/// )
/// ```
class OptimizedTextField extends StatefulWidget {
  /// Field label text
  final String label;

  /// Prefix icon
  final IconData icon;

  /// Text editing controller
  final TextEditingController controller;

  /// Whether this is a password field
  final bool isPassword;

  /// Keyboard input type
  final TextInputType keyboardType;

  /// Validation function
  final String? Function(String?) validator;

  /// Border radius
  final double borderRadius;

  /// Content padding
  final EdgeInsets contentPadding;

  const OptimizedTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.validator,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.borderRadius = 16,
    this.contentPadding = const EdgeInsets.all(20),
  });

  @override
  State<OptimizedTextField> createState() => _OptimizedTextFieldState();
}

class _OptimizedTextFieldState extends State<OptimizedTextField> {
  late final FocusNode _focusNode;
  late final ValueNotifier<bool> _hasText;
  late final ValueNotifier<bool> _isValid;
  late final ValueNotifier<bool> _isFocused;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _setupListeners();
  }

  void _initializeState() {
    _focusNode = FocusNode();
    _hasText = ValueNotifier(widget.controller.text.isNotEmpty);
    _isValid = ValueNotifier(_validateText(widget.controller.text));
    _isFocused = ValueNotifier(false);
  }

  void _setupListeners() {
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    _hasText.value = text.isNotEmpty;
    _isValid.value = _validateText(text);
  }

  void _onFocusChanged() {
    _isFocused.value = _focusNode.hasFocus;
  }

  bool _validateText(String text) {
    return widget.validator(text) == null;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<bool>(
        valueListenable: _hasText,
        builder: (context, hasText, _) => ValueListenableBuilder<bool>(
          valueListenable: _isValid,
          builder: (context, isValid, _) => ValueListenableBuilder<bool>(
            valueListenable: _isFocused,
            builder: (context, isFocused, _) {
              final borderColor = _getBorderColor(hasText, isValid, isFocused);
              final shouldShowShadow = hasText || isFocused;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: shouldShowShadow
                      ? [
                          BoxShadow(
                            color: borderColor.withValues(alpha: 0.15),
                            blurRadius: isFocused ? 12 : 8,
                            offset: Offset(0, isFocused ? 6 : 4),
                            spreadRadius: isFocused ? 1 : 0,
                          ),
                        ]
                      : null,
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.isPassword,
                  style: _getTextStyle(context),
                  decoration: _buildInputDecoration(
                    borderColor,
                    hasText,
                    isValid,
                    isFocused,
                  ),
                  validator: widget.validator,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(bool hasText, bool isValid, bool isFocused) {
    if (!hasText && !isFocused) return AppColors.inputBorder;
    if (isFocused) {
      return hasText
          ? (isValid ? AppColors.successColor : AppColors.errorColor)
          : AppColors.primaryColor;
    }
    return isValid ? AppColors.successColor : AppColors.errorColor;
  }

  TextStyle _getTextStyle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth > 400 ? 16.0 : 14.0;

    return TextStyle(
      color: AppColors.textEnabledColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
  }

  InputDecoration _buildInputDecoration(
    Color borderColor,
    bool hasText,
    bool isValid,
    bool isFocused,
  ) {
    return InputDecoration(
      labelText: widget.label,
      labelStyle: TextStyle(
        color: isFocused ? borderColor : AppColors.inputIcon,
        fontWeight: isFocused ? FontWeight.w500 : FontWeight.normal,
      ),
      prefixIcon: Icon(
        widget.icon,
        color: isFocused ? borderColor : AppColors.inputIcon,
        size: 22,
      ),
      suffixIcon: _buildSuffixIcon(hasText, isValid),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: borderColor,
          width: hasText ? 1.5 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: borderColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: const BorderSide(
          color: AppColors.errorColor,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: const BorderSide(
          color: AppColors.errorColor,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: AppColors.backgroundOverlay.withValues(alpha: 0.8),
      contentPadding: widget.contentPadding,
      errorStyle: const TextStyle(
        color: AppColors.errorColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget? _buildSuffixIcon(bool hasText, bool isValid) {
    if (!hasText) return null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        isValid ? Icons.check_circle : Icons.error,
        color: isValid ? AppColors.successColor : AppColors.errorColor,
        size: 22,
        key: ValueKey(isValid),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _hasText.dispose();
    _isValid.dispose();
    _isFocused.dispose();
    super.dispose();
  }
}
