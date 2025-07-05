import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class MatchTileButton extends StatelessWidget {
  final bool isSelected;
  final String opponentName;
  final String matchTime;
  final VoidCallback? onTap;
  final double screenWidth;
  final double screenHeight;
  final double fontSizeMultiplier;

  const MatchTileButton({
    super.key,
    required this.isSelected,
    required this.opponentName,
    required this.matchTime,
    this.onTap,
    required this.screenWidth,
    required this.screenHeight,
    this.fontSizeMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
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
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 6)
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              opponentName,
              style: TextStyle(
                fontSize: 18 * fontSizeMultiplier,
                color: AppColors.textEnabledColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              matchTime,
              style: TextStyle(
                fontSize: 14 * fontSizeMultiplier,
                color: AppColors.textEnabledColor,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
