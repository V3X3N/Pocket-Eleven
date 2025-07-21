import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';

class PlayerDetailsDialog extends StatelessWidget {
  final Player player;

  const PlayerDetailsDialog({super.key, required this.player});

  static final Map<String, ImageProvider> _imageCache = {};

  ImageProvider _getCachedImage(String path) =>
      _imageCache.putIfAbsent(path, () => AssetImage(path));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 400;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: RepaintBoundary(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isSmall ? size.width * 0.9 : 400,
            maxHeight: size.height * 0.7,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.secondaryColor, AppColors.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
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
              _buildHeader(isSmall),
              SizedBox(height: isSmall ? 16 : 20),
              _buildPlayerInfo(isSmall),
              SizedBox(height: isSmall ? 16 : 20),
              _buildStats(isSmall),
              SizedBox(height: isSmall ? 20 : 24),
              _buildCloseButton(context, isSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmall) {
    return Column(
      children: [
        RepaintBoundary(
          child: Container(
            width: isSmall ? 60 : 70,
            height: isSmall ? 60 : 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.blueColor, AppColors.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image(
                image: _getCachedImage(player.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.person,
                  color: AppColors.textEnabledColor,
                  size: isSmall ? 30 : 35,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: isSmall ? 12 : 16),
        Text(
          player.name,
          style: TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: isSmall ? 18 : 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.blueColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.blueColor.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Text(
            player.position,
            style: TextStyle(
              color: AppColors.blueColor,
              fontSize: isSmall ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerInfo(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.hoverColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _InfoItem(
            value: player.ovr.toString(),
            label: 'Overall',
            color: AppColors.green,
            isSmall: isSmall,
          ),
          _Divider(isSmall: isSmall),
          _InfoItem(
            value: player.age.toString(),
            label: 'Age',
            color: AppColors.textEnabledColor,
            isSmall: isSmall,
          ),
          _Divider(isSmall: isSmall),
          RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image(
                image: _getCachedImage(player.flagPath),
                width: isSmall ? 24 : 30,
                height: isSmall ? 24 : 30,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.flag_outlined,
                  size: isSmall ? 20 : 24,
                  color: AppColors.borderColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isSmall) {
    final stats = [
      ('Salary', player.salary.toString(), AppColors.coffeeText),
      ('Value', player.value.toString(), AppColors.green),
      (player.param1Name, player.param1.toString(), AppColors.textEnabledColor),
      (player.param2Name, player.param2.toString(), AppColors.textEnabledColor),
      (player.param3Name, player.param3.toString(), AppColors.textEnabledColor),
      (player.param4Name, player.param4.toString(), AppColors.textEnabledColor),
    ];

    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.accentColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: stats
            .map((stat) => Padding(
                  padding: EdgeInsets.symmetric(vertical: isSmall ? 4 : 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${stat.$1}:',
                        style: TextStyle(
                          color: AppColors.coffeeText,
                          fontSize: isSmall ? 14 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        stat.$2,
                        style: TextStyle(
                          color: stat.$3,
                          fontSize: isSmall ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context, bool isSmall) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorColor,
          foregroundColor: AppColors.textEnabledColor,
          padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          'Close',
          style: TextStyle(
            fontSize: isSmall ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isSmall;

  const _InfoItem({
    required this.value,
    required this.label,
    required this.color,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isSmall ? 18 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.coffeeText,
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isSmall;

  const _Divider({required this.isSmall});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: isSmall ? 30 : 36,
      color: AppColors.borderColor.withValues(alpha: 0.4),
    );
  }
}
