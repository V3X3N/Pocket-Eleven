import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class LeagueView extends StatelessWidget {
  const LeagueView(
      {required this.screenWidth, required this.screenHeight, super.key});

  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: screenWidth,
      height: screenHeight,
      child: const Center(
        child: Text(
          // TODO: Implement league data from firestore
          'Standings Container',
          style: TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
