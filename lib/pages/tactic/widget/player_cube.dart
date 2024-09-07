import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:pocket_eleven/design/colors.dart';

class PlayerCube extends StatelessWidget {
  final String name;
  final String imagePath;
  final VoidCallback onTap;

  const PlayerCube({
    Key? key,
    required this.name,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  // Funkcja zwracająca kolor w zależności od ścieżki obrazka
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
        return Colors
            .green; // Domyślny kolor, jeśli obrazek nie pasuje do żadnego
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              _getContainerColor(), // Użycie odpowiedniego koloru na podstawie obrazka
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikona użytkownika zamiast obrazka, używana, jeśli obrazek nie jest dostępny
            Expanded(
              child: Icon(
                UniconsLine.user, // Ikona użytkownika z Unicons
                color: AppColors.textEnabledColor,
                size: 40,
              ),
            ),
            // Dopasowanie tekstu do rozmiaru kontenera
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textEnabledColor, // Kolor tekstu
                    fontSize: 12, // Skalowanie tekstu
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
