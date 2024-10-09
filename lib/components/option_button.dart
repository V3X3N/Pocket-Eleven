import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class OptionButton extends StatelessWidget {
  final int? index;
  final int? selectedIndex;
  final VoidCallback? onTap;
  final String text;
  final double screenWidth;
  final double screenHeight;
  final double fontSizeMultiplier; // Opcjonalny mnożnik dla fontSize

  const OptionButton({
    super.key,
    this.index,
    this.selectedIndex,
    this.onTap,
    required this.text,
    required this.screenWidth,
    required this.screenHeight,
    this.fontSizeMultiplier = 1.0, // Domyślna wartość mnożnika
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01, horizontal: screenWidth * 0.03),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: AppColors.borderColor,
          ),
          color: isSelected ? AppColors.blueColor : AppColors.buttonColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 6)
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize:
                18 * fontSizeMultiplier, // Użyj mnożnika do obliczenia fontSize
            color: isSelected
                ? AppColors.textEnabledColor
                : AppColors.textEnabledColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
