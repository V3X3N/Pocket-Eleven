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

  // Optimized capacity calculation - computed once per build
  int get _stadiumCapacity {
    final sectors = sectorLevel;
    if (sectors == null || sectors.isEmpty) return 0;

    // More efficient than fold() for performance
    int total = 0;
    for (final level in sectors.values) {
      total += level;
    }
    return total * 1000;
  }

  // Cached text styles to avoid recreation
  static const _headerStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textEnabledColor,
  );

  static const _levelStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textEnabledColor,
  );

  static const _costStyle = TextStyle(
    color: AppColors.textEnabledColor,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );

  // Cached tooltip decoration
  static final _tooltipDecoration = BoxDecoration(
    color: AppColors.hoverColor,
    borderRadius: BorderRadius.circular(10.0),
  );

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final capacityMessage = 'Stadium Capacity: $_stadiumCapacity seats';

    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(headerText, style: _headerStyle),
                Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  message: capacityMessage,
                  decoration: _tooltipDecoration,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Level $level', style: _levelStyle),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              OptionButton(
                onTap: isUpgradeEnabled ? onUpgradePressed : null,
                text: "Upgrade",
                screenWidth: screenSize.width,
                screenHeight: screenSize.height,
              ),
              const SizedBox(height: 8.0),
              Text('Cost: $upgradeCost', style: _costStyle),
            ],
          ),
        ],
      ),
    );
  }
}
