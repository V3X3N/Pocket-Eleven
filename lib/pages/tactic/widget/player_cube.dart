import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:pocket_eleven/design/colors.dart';

class PlayerCube extends StatelessWidget {
  final String name;
  final String imagePath;
  final VoidCallback onTap;

  const PlayerCube({
    super.key,
    required this.name,
    required this.imagePath,
    required this.onTap,
  });

  Color _getContainerColor() {
    switch (imagePath) {
      case 'assets/players/player_card_bronze.png':
        return AppColors.playerBronze;
      case 'assets/players/player_card_silver.png':
        return AppColors.playerSilver;
      case 'assets/players/player_card_gold.png':
        return AppColors.playerGold;
      case 'assets/players/player_card_purple.png':
        return AppColors.playerPurple;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: _getContainerColor(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              UniconsLine.user,
              color: AppColors.textEnabledColor,
              size: 40,
            ),
            const SizedBox(height: 8.0),
            Text(
              name,
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
