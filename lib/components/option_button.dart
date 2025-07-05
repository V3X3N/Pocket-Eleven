import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class OptionButton extends StatelessWidget {
  final int? index;
  final int? selectedIndex;
  final VoidCallback? onTap;
  final String text;
  final double screenWidth;
  final double screenHeight;
  final double fontSizeMultiplier;

  const OptionButton({
    super.key,
    this.index,
    this.selectedIndex,
    this.onTap,
    required this.text,
    required this.screenWidth,
    required this.screenHeight,
    this.fontSizeMultiplier = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01,
            horizontal: screenWidth * 0.03,
          ),
          decoration: BoxDecoration(
            border: _border,
            color: isSelected ? AppColors.blueColor : AppColors.buttonColor,
            borderRadius: _borderRadius,
            boxShadow: isSelected ? _selectedShadow : null,
          ),
          child: Text(
            text,
            style: _getTextStyle(fontSizeMultiplier, isSelected),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  // Cached objects - to są kluczowe optymalizacje
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const BorderRadius _borderRadius =
      BorderRadius.all(Radius.circular(12));
  static const Border _border = Border.fromBorderSide(
    BorderSide(width: 1, color: AppColors.borderColor),
  );
  static final List<BoxShadow> _selectedShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 6,
    ),
  ];

  // Cache dla TextStyle - tylko jeśli masz dużo buttonów
  static final Map<String, TextStyle> _textStyleCache = {};

  static TextStyle _getTextStyle(double fontSizeMultiplier, bool isSelected) {
    final key = '${fontSizeMultiplier}_$isSelected';
    return _textStyleCache.putIfAbsent(
        key,
        () => TextStyle(
              fontSize: 18 * fontSizeMultiplier,
              color: AppColors.textEnabledColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ));
  }
}
