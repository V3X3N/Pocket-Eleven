import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// Modern, interactive avatar widget with glassmorphism design.
///
/// Features:
/// - Responsive sizing based on device type
/// - Glassmorphism visual effects with gradients and shadows
/// - Optimized image loading with caching
/// - Smooth touch feedback animations
/// - Customizable tap behavior
///
/// Performance optimizations:
/// - RepaintBoundary for isolated repainting
/// - Const constructors where possible
/// - Efficient shadow and gradient implementations
class ModernAvatar extends StatelessWidget {
  /// Avatar ID for image asset (1-10)
  final int avatarId;

  /// Size of the avatar (auto-calculated if not provided)
  final double? size;

  /// Callback when avatar is tapped
  final VoidCallback? onTap;

  /// Whether this is a tablet layout
  final bool isTablet;

  const ModernAvatar({
    super.key,
    required this.avatarId,
    this.size,
    this.onTap,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? (isTablet ? 120.0 : 100.0);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: avatarSize,
          width: avatarSize,
          decoration: _buildAvatarDecoration(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                _buildAvatarImage(),
                _buildGlassmorphismOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Creates the main avatar decoration with shadows and borders
  BoxDecoration _buildAvatarDecoration() => BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 2,
          color: AppColors.borderColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.accentColor.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: 4,
          ),
        ],
      );

  /// Optimized avatar image with error handling
  Widget _buildAvatarImage() => Image.asset(
        'assets/crests/crest_$avatarId.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.hoverColor,
          child: const Icon(
            Icons.person,
            color: AppColors.textEnabledColor,
            size: 40,
          ),
        ),
      );

  /// Glassmorphism overlay effect
  Widget _buildGlassmorphismOverlay() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.textEnabledColor.withValues(alpha: 0.1),
              Colors.transparent,
              AppColors.primaryColor.withValues(alpha: 0.1),
            ],
          ),
        ),
      );
}
