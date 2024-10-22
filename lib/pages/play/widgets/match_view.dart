import 'package:flutter/material.dart';
import 'package:pocket_eleven/pages/play/class/club_container.dart';
import 'package:pocket_eleven/pages/play/class/matches_container.dart';

class MatchView extends StatelessWidget {
  const MatchView({
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClubInfoContainer(screenWidth: screenWidth, screenHeight: screenHeight),
        Expanded(
          child: MatchesContainer(
              screenWidth: screenWidth, screenHeight: screenHeight),
        ),
      ],
    );
  }
}
