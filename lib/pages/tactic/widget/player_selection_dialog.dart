import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/name_formatter.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/models/player.dart';

class PlayerSelectionDialog extends StatelessWidget {
  final List<Player> players;

  const PlayerSelectionDialog({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: AppColors.hoverColor,
            border: Border.all(color: AppColors.borderColor, width: 1),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select a Player',
                  style: TextStyle(
                      color: AppColors.textEnabledColor, fontSize: 18),
                ),
              ),
              players.isEmpty
                  ? const Text('No players found',
                      style: TextStyle(color: AppColors.textEnabledColor))
                  : SizedBox(
                      height: screenHeight * 0.4,
                      width: double.maxFinite,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 8.0, // Odstępy poziome
                          mainAxisSpacing: 8.0, // Odstępy pionowe
                        ),
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(players[index]);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.buttonColor,
                                border: Border.all(
                                  color: AppColors.borderColor,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    players[index].imagePath,
                                    height: 80,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    formatPlayerName(players[index].name),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textEnabledColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
