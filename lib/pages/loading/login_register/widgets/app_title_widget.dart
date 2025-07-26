import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// Creates a clean, responsive title without decorative elements.

class AppTitle extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final double letterSpacing;

  const AppTitle({
    super.key,
    required this.title,
    this.fontSize = 32,
    this.fontWeight = FontWeight.bold,
    this.color = AppColors.textEnabledColor,
    this.letterSpacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveFontSize = screenWidth > 400 ? fontSize : fontSize * 0.8;

    return Text(
      title,
      style: TextStyle(
        fontSize: responsiveFontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      ),
      textAlign: TextAlign.center,
    );
  }
}
