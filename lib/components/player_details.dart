import 'package:flutter/material.dart';
import 'package:pocket_eleven/player.dart';
import 'package:pocket_eleven/design/colors.dart';

class PlayerDetailsDialog extends StatelessWidget {
  final Player player;

  const PlayerDetailsDialog({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.primaryColor,
      title: Text(
        player.name,
        style: const TextStyle(
          color: AppColors.textEnabledColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(player.imagePath),
            ),
            const SizedBox(height: 16),
            Text(
              'Position: ${player.position}',
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rating: ${player.ovr}',
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Age: ${player.age}',
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nationality: ${player.nationality}',
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${player.param1Name}: ${player.param1}',
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${player.param2Name}: ${player.param2}',
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${player.param3Name}: ${player.param3}',
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${player.param4Name}: ${player.param4}',
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Close',
            style: TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
