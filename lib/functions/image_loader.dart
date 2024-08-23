import 'package:flutter/material.dart';

class ImageLoader {
  static Future<void> precacheImages(BuildContext context) async {
    List<String> imagePaths = [
      'assets/background/loading_bg.png',
      //Badges
      'assets/players/player_card_bronze.png',
      'assets/players/player_card_silver.png',
      'assets/players/player_card_gold.png',
      'assets/players/player_card_purple.png',
      //Flags
      'assets/flags/flag_AUT.png',
      'assets/flags/flag_BEL.png',
      'assets/flags/flag_BRA.png',
      'assets/flags/flag_ENG.png',
      'assets/flags/flag_ESP.png',
      'assets/flags/flag_FRA.png',
      'assets/flags/flag_GER.png',
      'assets/flags/flag_ITA.png',
      'assets/flags/flag_JPN.png',
      'assets/flags/flag_POL.png',
      'assets/flags/flag_TUR.png',
      'assets/flags/flag_USA.png',
      //Club
      'assets/background/club_youth.png',
      'assets/background/club_medical.png',
      'assets/background/club_training.png',
      'assets/background/club_stadion.png',
    ];

    for (var imagePath in imagePaths) {
      await precacheImage(AssetImage(imagePath), context);
    }
  }
}
