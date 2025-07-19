import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// Modern user information display card with glassmorphism design.
///
/// Features:
/// - Responsive typography scaling
/// - Glassmorphism visual effects
/// - Smooth loading state animations
/// - Optimized text rendering
/// - Flexible layout for different screen sizes
///
/// Performance optimizations:
/// - Const text widgets where possible
/// - Efficient gradient implementations
/// - Optimized widget tree structure
class UserInfoCard extends StatelessWidget {
  /// User's manager name to display
  final String? managerName;

  /// User's club name to display
  final String? clubName;

  /// User's email address to display
  final String? email;

  /// Whether this is a tablet layout
  final bool isTablet;

  const UserInfoCard({
    super.key,
    this.managerName,
    this.clubName,
    this.email,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildManagerInfo(),
          if (email != null) ...[
            const SizedBox(height: 24),
            _buildEmailInfo(),
          ],
        ],
      ),
    );
  }

  /// Builds the manager name and club information section
  Widget _buildManagerInfo() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildManagerName(),
          const SizedBox(height: 8),
          _buildClubName(),
          const SizedBox(height: 4),
          _buildManagerLabel(),
        ],
      );

  /// Manager name with responsive typography
  Widget _buildManagerName() => AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: AppColors.textEnabledColor,
          fontSize: isTablet ? 32 : 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        child: Text(
          managerName ?? 'Loading...',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );

  /// Club name with subtle styling
  Widget _buildClubName() => AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: AppColors.textEnabledColor.withValues(alpha: 0.85),
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        child: Text(
          clubName ?? 'Loading...',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );

  /// Manager role label
  Widget _buildManagerLabel() => Text(
        'Manager',
        style: TextStyle(
          color: AppColors.textEnabledColor.withValues(alpha: 0.6),
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w400,
        ),
      );

  /// Email information with glassmorphism container
  Widget _buildEmailInfo() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.hoverColor.withValues(alpha: 0.3),
              AppColors.accentColor.withValues(alpha: 0.2),
            ],
          ),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.email_outlined,
              color: AppColors.textEnabledColor.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                email ?? 'Loading...',
                style: const TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}
