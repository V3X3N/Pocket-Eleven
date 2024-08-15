import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/components/player_details.dart';

class PlayerCard extends StatelessWidget {
  final Player player;

  const PlayerCard({super.key, required this.player});

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
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        color: AppColors.hoverColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textEnabledColor,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                'Position: ${player.position}',
                style: const TextStyle(
                  fontSize: 18.0,
                  color: AppColors.textEnabledColor,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                'Nationality: ${player.nationality}',
                style: const TextStyle(
                  fontSize: 18.0,
                  color: AppColors.textEnabledColor,
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                'Rating: ${player.ovr}',
                style: const TextStyle(
                  fontSize: 18.0,
                  color: AppColors.textEnabledColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
