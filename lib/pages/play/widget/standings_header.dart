import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class StandingsHeader extends StatelessWidget {
  const StandingsHeader({required this.screenWidth, super.key});

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.01, horizontal: screenWidth * 0.02),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Team',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textEnabledColor,
              ),
            ),
          ),
          _HeaderColumn('MP'),
          _HeaderColumn('GF'),
          _HeaderColumn('GA'),
          _HeaderColumn('GD'),
          _HeaderColumn('Pts'),
        ],
      ),
    );
  }
}

class _HeaderColumn extends StatelessWidget {
  const _HeaderColumn(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textEnabledColor,
          ),
        ),
      ),
    );
  }
}
