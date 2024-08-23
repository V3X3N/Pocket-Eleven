import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class PlayersView extends StatelessWidget {
  const PlayersView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

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
          // TODO: Implement players data from firestore
          'Players Container',
          style: TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}