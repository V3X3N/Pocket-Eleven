import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class AvatarSelector extends StatelessWidget {
  final Future<void> Function(int avatarIndex) updateAvatar;

  const AvatarSelector({super.key, required this.updateAvatar});

  static const int _avatarCount = 10;
  static const int _crossAxisCount = 5;
  static const double _spacing = 10.0;
  static const double _borderRadius = 10.0;

  Future<void> _updateAvatar(BuildContext context, int avatarIndex) async {
    try {
      await updateAvatar(avatarIndex);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update avatar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.8;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: RepaintBoundary(
        child: Container(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: AppColors.hoverColor,
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(_borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Avatar',
                style: TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildAvatarGrid(context),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        crossAxisSpacing: _spacing,
        mainAxisSpacing: _spacing,
        childAspectRatio: 1.0,
      ),
      itemCount: _avatarCount,
      itemBuilder: (context, index) => _AvatarItem(
        avatarIndex: index + 1,
        onTap: () => _updateAvatar(context, index + 1),
      ),
    );
  }
}

class _AvatarItem extends StatelessWidget {
  final int avatarIndex;
  final VoidCallback onTap;

  const _AvatarItem({
    required this.avatarIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AvatarSelector._borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AvatarSelector._borderRadius),
              border: Border.all(color: AppColors.borderColor),
              image: DecorationImage(
                image: AssetImage('assets/crests/crest_$avatarIndex.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
