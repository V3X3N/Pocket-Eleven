import 'package:flutter/material.dart';

class AppColors {
  // Main brand colors
  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color secondaryColor = Color(0xFF16213E);
  static const Color accentColor = Color(0xFF0F3460);

  // UI colors
  static const Color textEnabledColor = Color(0xFFF8F5FA);
  static const Color coffeeText = Color(0xFFE1DCCE);
  static const Color borderColor = Color(0xFF717483);

  // Interactive colors
  static const Color green = Color(0xFF028A0F);
  static const Color blueColor = Color(0xFF2697FF);
  static const Color hoverColor = Color(0xFF212332);
  static const Color buttonColor = Color(0xFF333645);

  // Player tier colors
  static const Color playerBronze = Color(0xFFB17251);
  static const Color playerSilver = Color(0xFFE1DFE3);
  static const Color playerGold = Color(0xFFEED088);
  static const Color playerPurple = Color(0xFFA780BE);

  // Additional UI colors from register page
  static const Color backgroundOverlay =
      Color(0x1AFFFFFF); // White with 10% opacity
  static const Color inputBorder = Color(0x4DFFFFFF); // White with 30% opacity
  static const Color inputIcon = Color(0xB3FFFFFF); // White with 70% opacity
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;

  // Password strength colors
  static const Color weakPassword = Colors.red;
  static const Color fairPassword = Colors.orange;
  static const Color goodPassword = Colors.yellow;
  static const Color strongPassword = Colors.green;
}
