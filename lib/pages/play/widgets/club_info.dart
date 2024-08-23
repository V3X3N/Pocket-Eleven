import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class ClubInfo extends StatelessWidget {
  const ClubInfo({
    required this.clubCrestPath,
    required this.clubName,
    super.key,
  });

  final String clubCrestPath;
  final String clubName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.width * 0.225,
          width: MediaQuery.of(context).size.width * 0.225,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.025),
            image: DecorationImage(
              image: AssetImage(clubCrestPath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Text(
          clubName,
          style: const TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
