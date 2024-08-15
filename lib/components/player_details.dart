import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';

class PlayerDetailsDialog extends StatelessWidget {
  final Player player;

  const PlayerDetailsDialog({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        color: AppColors.primaryColor,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${player.name} (${player.position})',
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
              childAspectRatio: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(player.imagePath),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'OVR: ${player.ovr}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textEnabledColor,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      player.flagPath,
                      width: 30,
                      height: 30,
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
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Salary: ${player.salary}',
                      style: const TextStyle(
                        color: AppColors.textEnabledColor,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Value: ${player.value}',
                      style: const TextStyle(
                        color: AppColors.textEnabledColor,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                Text(
                  '${player.param1Name}:',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 22,
                  ),
                ),
                Text(
                  '${player.param1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 22,
                  ),
                ),
                Text(
                  '${player.param2Name}:',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 22,
                  ),
                ),
                Text(
                  '${player.param2}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 22,
                  ),
                ),
                Text(
                  '${player.param3Name}:',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 22,
                  ),
                ),
                Text(
                  '${player.param3}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 22,
                  ),
                ),
                Text(
                  '${player.param4Name}:',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 22,
                  ),
                ),
                Text(
                  '${player.param4}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 22,
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
