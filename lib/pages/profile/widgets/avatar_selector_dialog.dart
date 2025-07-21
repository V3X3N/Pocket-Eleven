import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// Modern avatar selection dialog with grid layout and glassmorphism design.
///
/// Features:
/// - Responsive grid layout for different screen sizes
/// - Smooth animations and transitions
/// - Glassmorphism visual effects
/// - Optimized image loading with error handling
/// - Customizable avatar count and selection callback
///
/// Performance optimizations:
/// - Efficient GridView with proper delegates
/// - RepaintBoundary for avatar items
/// - Optimized dialog animations
/// - Cached image loading
class AvatarSelectorDialog extends StatelessWidget {
  /// Current selected avatar ID
  final int currentAvatarId;

  /// Total number of available avatars
  final int maxAvatars;

  /// Callback when an avatar is selected
  final ValueChanged<int> onAvatarSelected;

  /// Whether this is a tablet layout
  final bool isTablet;

  const AvatarSelectorDialog({
    super.key,
    required this.currentAvatarId,
    required this.maxAvatars,
    required this.onAvatarSelected,
    this.isTablet = false,
  });

  /// Shows the avatar selector dialog
  static Future<void> show({
    required BuildContext context,
    required int currentAvatarId,
    required int maxAvatars,
    required ValueChanged<int> onAvatarSelected,
    bool isTablet = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AvatarSelectorDialog(
        currentAvatarId: currentAvatarId,
        maxAvatars: maxAvatars,
        onAvatarSelected: onAvatarSelected,
        isTablet: isTablet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 500 : 350,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: _buildDialogContent(context),
      ),
    );
  }

  /// Builds the main dialog content with glassmorphism design
  Widget _buildDialogContent(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.hoverColor.withValues(alpha: 0.95),
              AppColors.accentColor.withValues(alpha: 0.9),
            ],
          ),
          border: Border.all(
            color: AppColors.borderColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(),
            const SizedBox(height: 24),
            _buildAvatarGrid(),
            const SizedBox(height: 24),
            _buildCancelButton(context),
          ],
        ),
      );

  /// Dialog title with modern typography
  Widget _buildTitle() => const Text(
        'Select Avatar',
        style: TextStyle(
          color: AppColors.textEnabledColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      );

  /// Avatar grid with responsive layout
  Widget _buildAvatarGrid() => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 5 : 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: maxAvatars,
        itemBuilder: (context, index) => _buildAvatarItem(context, index + 1),
      );

  /// Individual avatar item with selection handling
  Widget _buildAvatarItem(BuildContext context, int avatarId) =>
      RepaintBoundary(
        child: GestureDetector(
          onTap: () {
            onAvatarSelected(avatarId);
            Navigator.of(context).pop();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: currentAvatarId == avatarId ? 3 : 1,
                color: currentAvatarId == avatarId
                    ? AppColors.blueColor
                    : AppColors.borderColor.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: currentAvatarId == avatarId
                      ? AppColors.blueColor.withValues(alpha: 0.3)
                      : AppColors.primaryColor.withValues(alpha: 0.2),
                  blurRadius: currentAvatarId == avatarId ? 15 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/crests/crest_$avatarId.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.hoverColor,
                  child: const Icon(
                    Icons.person,
                    color: AppColors.textEnabledColor,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  /// Cancel button with modern styling
  Widget _buildCancelButton(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.errorColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
}
