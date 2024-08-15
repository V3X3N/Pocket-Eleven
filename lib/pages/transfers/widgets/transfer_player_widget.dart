import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';

class TransfersPlayerWidget extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;

  const TransfersPlayerWidget({
    super.key,
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Flag
            Image.asset(
              player.flagPath,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),

            // Player Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      color: AppColors.textEnabledColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Position: ${player.position}',
                    style: const TextStyle(
                      color: AppColors.textEnabledColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'OVR: ${player.ovr}',
                    style: const TextStyle(
                      color: AppColors.textEnabledColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark Button
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
