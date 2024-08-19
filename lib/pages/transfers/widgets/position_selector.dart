import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class PositionSelector extends StatelessWidget {
  final String selectedPosition;
  final bool canScout;
  final ValueChanged<String> onPositionChange;

  const PositionSelector({
    super.key,
    required this.selectedPosition,
    required this.canScout,
    required this.onPositionChange,
  });

  @override
  Widget build(BuildContext context) {
    final positions = [
      'LW',
      'ST',
      'RW',
      'LM',
      'CAM',
      'CM',
      'CDM',
      'RM',
      'LB',
      'CB',
      'RB',
      'GK'
    ];

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: positions.map((position) {
          return GestureDetector(
            onTap: () {
              if (canScout) {
                onPositionChange(position);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: selectedPosition == position
                    ? AppColors.blueColor
                    : AppColors.buttonColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  position,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textEnabledColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
