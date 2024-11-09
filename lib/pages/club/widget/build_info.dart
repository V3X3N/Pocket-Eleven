import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';

class BuildInfo extends StatelessWidget {
  final String headerText;
  final int level;
  final int upgradeCost;
  final bool isUpgradeEnabled;
  final VoidCallback? onUpgradePressed;

  const BuildInfo({
    super.key,
    required this.headerText,
    required this.level,
    required this.upgradeCost,
    required this.isUpgradeEnabled,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    int trainingCost = 10000 - ((level - 1) * 500);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headerText,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textEnabledColor,
                ),
              ),
              Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: 'Current training cost: $trainingCost',
                decoration: BoxDecoration(
                  color: AppColors.hoverColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Text(
                      'Level $level',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textEnabledColor,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.textEnabledColor,
                      size: 16.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            OptionButton(
              onTap: isUpgradeEnabled ? onUpgradePressed : null,
              text: "Upgrade",
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Cost: $upgradeCost',
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
