import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';

class StadiumInfo extends StatelessWidget {
  final String headerText;
  final int level;
  final int upgradeCost;
  final bool isUpgradeEnabled;
  final VoidCallback? onUpgradePressed;
  final Map<String, int>? sectorLevel;

  const StadiumInfo({
    super.key,
    required this.headerText,
    required this.level,
    required this.upgradeCost,
    required this.isUpgradeEnabled,
    this.onUpgradePressed,
    this.sectorLevel,
  });

  int _calculateStadiumCapacity() {
    if (sectorLevel == null) {
      return 0;
    }

    int totalSectorLevels =
        sectorLevel!.values.fold(0, (sum, level) => sum + level);
    return totalSectorLevels * 1000;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

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
                message:
                    'Stadium Capacity: ${_calculateStadiumCapacity()} seats',
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
              const SizedBox(height: 8.0),
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
