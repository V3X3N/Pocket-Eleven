import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/play/widgets/club_info.dart';

class ClubInfoContainer extends StatelessWidget {
  const ClubInfoContainer({
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.05),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          border: Border.all(color: AppColors.borderColor, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        height: screenHeight * 0.25,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ClubInfo(
              // TODO: Implement firestore info
              clubCrestPath: 'assets/crests/crest_1.png',
              clubName: 'ClubName',
            ),
            ClubInfo(
              // TODO: Implement firestore info
              clubCrestPath: 'assets/crests/crest_2.png',
              clubName: 'Klub 2',
            ),
          ],
        ),
      ),
    );
  }
}
