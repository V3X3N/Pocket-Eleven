// File: widgets/form/password_strength_indicator.dart
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// **Animated password strength indicator with visual feedback**
///
/// Displays real-time password strength analysis with:
/// - Color-coded strength levels
/// - Animated progress bar
/// - Descriptive labels
/// - Modern glassmorphism design
///
/// **Parameters:**
/// - [strength] - Password strength level (0-4) (required)
/// - [password] - Current password text for analysis (required)
/// - [labels] - Custom strength labels (optional)
/// - [colors] - Custom color scheme (optional)
/// - [borderRadius] - Container border radius (default: 16)
/// - [padding] - Container padding (default: 16 all)
/// - [showDetails] - Show detailed strength info (default: false)
///
/// **Usage:**
/// ```dart
/// PasswordStrengthIndicator(
///   strength: 3,
///   password: 'myPassword123!',
///   showDetails: true,
/// )
/// ```
class PasswordStrengthIndicator extends StatelessWidget {
  /// Password strength level (0-4)
  final int strength;

  /// Current password text
  final String password;

  /// Custom strength level labels
  final List<String>? labels;

  /// Custom color scheme for strength levels
  final List<Color>? colors;

  /// Container border radius
  final double borderRadius;

  /// Container padding
  final EdgeInsets padding;

  /// Whether to show detailed strength criteria
  final bool showDetails;

  /// Default strength labels
  static const _defaultLabels = ['Very Weak', 'Weak', 'Fair', 'Good', 'Strong'];

  /// Default color scheme
  static const _defaultColors = [
    AppColors.errorColor,
    AppColors.weakPassword,
    AppColors.fairPassword,
    AppColors.goodPassword,
    AppColors.strongPassword,
  ];

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
    required this.password,
    this.labels,
    this.colors,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strengthColors = colors ?? _defaultColors;
    final strengthLabels = labels ?? _defaultLabels;
    final clampedStrength = strength.clamp(0, 4);
    final currentColor = strengthColors[clampedStrength];
    final currentLabel = strengthLabels[clampedStrength];

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: AppColors.backgroundOverlay.withValues(alpha: 0.9),
          border: Border.all(
            color: currentColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: currentColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(currentLabel, currentColor),
            const SizedBox(height: 12),
            _buildProgressBar(clampedStrength, currentColor),
            if (showDetails) ...[
              const SizedBox(height: 16),
              _buildStrengthDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String label, Color color) {
    return Row(
      children: [
        Icon(
          _getStrengthIcon(strength),
          color: color,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Password Strength: $label',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(int clampedStrength, Color color) {
    return Row(
      children: List.generate(5, (index) {
        final isActive = index <= clampedStrength;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(
              right: index < 4 ? 4 : 0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: isActive
                  ? color
                  : AppColors.inputBorder.withValues(alpha: 0.3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStrengthDetails() {
    final criteria = _getPasswordCriteria();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Requirements:',
          style: TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...criteria.map((criterion) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    criterion.isMet
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: criterion.isMet
                        ? AppColors.successColor
                        : AppColors.inputIcon,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      criterion.text,
                      style: TextStyle(
                        color: criterion.isMet
                            ? AppColors.successColor
                            : AppColors.inputIcon,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  IconData _getStrengthIcon(int strength) {
    switch (strength.clamp(0, 4)) {
      case 0:
      case 1:
        return Icons.security;
      case 2:
        return Icons.shield;
      case 3:
        return Icons.verified_user;
      case 4:
        return Icons.gpp_good;
      default:
        return Icons.security;
    }
  }

  List<_PasswordCriterion> _getPasswordCriteria() {
    return [
      _PasswordCriterion(
        text: 'At least 8 characters',
        isMet: password.length >= 8,
      ),
      _PasswordCriterion(
        text: 'Contains numbers',
        isMet: RegExp(r'[0-9]').hasMatch(password),
      ),
      _PasswordCriterion(
        text: 'Contains letters',
        isMet: RegExp(r'[a-zA-Z]').hasMatch(password),
      ),
      _PasswordCriterion(
        text: 'Contains special characters',
        isMet: RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      ),
      _PasswordCriterion(
        text: 'Mix of uppercase and lowercase',
        isMet: RegExp(r'[a-z]').hasMatch(password) &&
            RegExp(r'[A-Z]').hasMatch(password),
      ),
    ];
  }
}

/// **Internal class for password criteria tracking**
class _PasswordCriterion {
  final String text;
  final bool isMet;

  const _PasswordCriterion({
    required this.text,
    required this.isMet,
  });
}
