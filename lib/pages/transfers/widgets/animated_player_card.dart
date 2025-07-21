import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfer_player_confirm_widget.dart';

/// An animated player card widget with smooth interactions and modern design.
///
/// Features:
/// - Smooth tap animations and selection states
/// - Performance optimized with RepaintBoundary
/// - Customizable selection styling
/// - Modern material design with InkWell
/// - Staggered animation support
class AnimatedPlayerCard extends StatelessWidget {
  /// Creates an animated player card.
  ///
  /// [player] - The player object to display (required)
  /// [isSelected] - Whether the card is currently selected (required)
  /// [onTap] - Callback function when card is tapped (required)
  /// [onPlayerSelected] - Callback function for player selection (required)
  /// [animationDelay] - Delay for staggered animations (default: 0)
  const AnimatedPlayerCard({
    super.key,
    required this.player,
    required this.isSelected,
    required this.onTap,
    required this.onPlayerSelected,
    this.animationDelay = 0,
  });

  /// The player object containing player information
  final Player player;

  /// Whether the card is currently selected
  final bool isSelected;

  /// Callback function when the card is tapped
  final VoidCallback onTap;

  /// Callback function for player selection state changes
  final Function(Player) onPlayerSelected;

  /// Animation delay in milliseconds for staggered animations
  final int animationDelay;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300 + animationDelay),
        curve: Curves.easeOutBack,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            splashColor: AppColors.textEnabledColor.withValues(alpha: 0.1),
            highlightColor: AppColors.textEnabledColor.withValues(alpha: 0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.textEnabledColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: AppColors.textEnabledColor, width: 2)
                    : Border.all(color: Colors.transparent, width: 2),
              ),
              child: TransferPlayerConfirmWidget(
                player: player,
                isSelected: isSelected,
                onPlayerSelected: onPlayerSelected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
