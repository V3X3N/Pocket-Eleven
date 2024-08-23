import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class MatchesContainer extends StatelessWidget {
  const MatchesContainer({
    required this.screenWidth,
    super.key,
  });

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.05),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: const Center(
        // TODO: Implement upcoming matches
        child: Text(
          'Matches Container',
          style: TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
