import 'package:flutter/material.dart';
import 'package:pocket_eleven/player.dart';
import 'package:pocket_eleven/design/colors.dart';

class PlayerDetailsDialog extends StatelessWidget {
  final Player player;

  const PlayerDetailsDialog({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        color: AppColors.primaryColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              player.name,
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(player.imagePath),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'OVR: ${player.ovr}',
                      style: const TextStyle(
                        color: AppColors.textEnabledColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/flags/${player.nationality}.png',
                      width: 30,
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Age: ${player.age}',
                      style: const TextStyle(
                        color: AppColors.textEnabledColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Salary: \$',
                      style: const TextStyle(
                        color: AppColors.textEnabledColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Value: \$\$',
                      style: const TextStyle(
                        color: AppColors.textEnabledColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                Text(
                  '${player.param1Name}:',
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${player.param1}',
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${player.param2Name}:',
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${player.param2}',
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${player.param3Name}:',
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${player.param3}',
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${player.param4Name}:',
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${player.param4}',
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
        ),
      ),
    );
  }
}
