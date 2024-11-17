import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/name_formatter.dart';
import 'package:pocket_eleven/components/player_details.dart';
import 'package:unicons/unicons.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/models/player.dart';

class PlayerCube extends StatelessWidget {
  final String name;
  final String imagePath;
  final Player player;
  final VoidCallback onTap;

  const PlayerCube({
    super.key,
    required this.name,
    required this.imagePath,
    required this.onTap,
    required this.player,
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
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return PlayerDetailsDialog(player: player);
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _getContainerColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              child: Icon(
                UniconsLine.user,
                color: AppColors.textEnabledColor,
                size: 40,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatPlayerName(name),
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
