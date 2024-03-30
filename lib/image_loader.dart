import 'package:flutter/material.dart';

class ImageLoader {
  static Future<void> precacheImages(BuildContext context) async {
    List<String> imagePaths = [
      'assets/background/loading_bg.png',
      'assets/background/stadium_bg.png',
      'assets/background/league_bg.png',
    ];

    for (var imagePath in imagePaths) {
      await precacheImage(AssetImage(imagePath), context);
    }
  }
}
