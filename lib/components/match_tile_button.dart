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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  opponentName,
                  style: _getOpponentTextStyle(fontSizeMultiplier, isSelected),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                matchTime,
                style: _getTimeTextStyle(fontSizeMultiplier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cached objects
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

  // TextStyle cache
  static final Map<String, TextStyle> _textStyleCache = {};

  static TextStyle _getOpponentTextStyle(
      double fontSizeMultiplier, bool isSelected) {
    final key = 'opponent_${fontSizeMultiplier}_$isSelected';
    return _textStyleCache.putIfAbsent(
        key,
        () => TextStyle(
              fontSize: 18 * fontSizeMultiplier,
              color: AppColors.textEnabledColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ));
  }

  static TextStyle _getTimeTextStyle(double fontSizeMultiplier) {
    final key = 'time_$fontSizeMultiplier';
    return _textStyleCache.putIfAbsent(
        key,
        () => TextStyle(
              fontSize: 14 * fontSizeMultiplier,
              color: AppColors.textEnabledColor,
              fontWeight: FontWeight.normal,
            ));
  }
}
