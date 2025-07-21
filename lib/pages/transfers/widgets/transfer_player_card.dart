import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';

class TransferPlayerCard extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onConfirm;

  const TransferPlayerCard({
    super.key,
    required this.player,
    required this.isSelected,
    this.onTap,
    this.onConfirm,
  });

  static final Map<String, ImageProvider> _imageCache = {};

  ImageProvider _getCachedImage(String flagPath) =>
      _imageCache.putIfAbsent(flagPath, () => AssetImage(flagPath));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [AppColors.hoverColor, AppColors.buttonColor]
                : [AppColors.blueColor, AppColors.accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isSelected ? null : onTap,
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      player.name,
                      style: TextStyle(
                        color: AppColors.textEnabledColor,
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: isTablet ? 16 : 12),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: isTablet ? 16 : 12,
                          runSpacing: 6,
                          children: [
                            _PlayerChip(label: player.position),
                            _PlayerChip(label: 'OVR ${player.ovr}'),
                            _PlayerChip(
                                label: '\$${player.value}', isPrice: true),
                          ],
                        ),
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image(
                          image: _getCachedImage(player.flagPath),
                          width: isTablet ? 32 : 28,
                          height: isTablet ? 32 : 28,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: isTablet ? 32 : 28,
                            height: isTablet ? 32 : 28,
                            decoration: BoxDecoration(
                              color: AppColors.hoverColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.flag_outlined,
                              size: isTablet ? 18 : 16,
                              color: AppColors.borderColor,
                            ),
                          ),
                        ),
                      ),
                      if (!isSelected) ...[
                        SizedBox(width: isTablet ? 12 : 8),
                        Material(
                          color: AppColors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: onConfirm,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.check_rounded,
                                color: AppColors.green,
                                size: isTablet ? 24 : 20,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}

class _PlayerChip extends StatelessWidget {
  final String label;
  final bool isPrice;

  const _PlayerChip({required this.label, this.isPrice = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPrice
            ? AppColors.green.withValues(alpha: 0.15)
            : AppColors.textEnabledColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrice
              ? AppColors.green.withValues(alpha: 0.4)
              : AppColors.textEnabledColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrice ? AppColors.green : AppColors.textEnabledColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
