import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class StandingsRow extends StatelessWidget {
  const StandingsRow({
    required this.teamName,
    required this.played,
    required this.scored,
    required this.conceded,
    required this.goalDifference,
    required this.points,
    required this.screenHeight,
    required this.screenWidth,
    super.key,
  });

  final String teamName;
  final int played;
  final int scored;
  final int conceded;
  final int goalDifference;
  final int points;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ExpandedText(teamName, flex: 3),
          _ExpandedText('$played'),
          _ExpandedText('$scored'),
          _ExpandedText('$conceded'),
          _ExpandedText('$goalDifference'),
          _ExpandedText('$points'),
        ],
      ),
    );
  }
}

class _ExpandedText extends StatelessWidget {
  const _ExpandedText(this.text, {this.flex = 1});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textEnabledColor),
        ),
      ),
    );
  }
}
